// supabase/functions/fetch-world-records/index.ts
//
// Descarga el CSV de mkwrs.com/data/mkworld_wrs.csv (historial completo de
// récords), se queda con la entrada mas reciente de cada circuito, y hace
// upsert en la tabla world_records (una fila por track_id).
//
// SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los inyecta Supabase
// automaticamente: no hace falta configurarlos a mano.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { parse } from 'https://deno.land/std@0.224.0/csv/mod.ts'

const CSV_URL = 'https://mkwrs.com/data/mkworld_wrs.csv'

// Indices de columna del CSV (sin cabecera). Ajusta si mkwrs.com cambia
// el formato: puedes comprobarlo descargando el CSV y mirando una fila.
const COL_PLAYER = 1
const COL_DATE = 2
const COL_TRACK = 3
const COL_TIME_MS = 4
const COL_VIDEO = 7

Deno.serve(async (_req: Request) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // 1. Descargar el CSV
    const res = await fetch(CSV_URL)
    if (!res.ok) {
      throw new Error(`No se pudo descargar el CSV: ${res.status}`)
    }
    const csvText = await res.text()

    // 2. Parsear el CSV (sin cabecera, valores entre comillas)
    const rows = parse(csvText, { skipFirstRow: false }) as string[][]

    // 3. Quedarnos con el registro mas reciente (= record actual) de
    // cada circuito. El CSV es el historial completo de progresion.
    type LatestRecord = {
      player: string
      date: string
      timeMs: number
      videoUrl: string | null
    }
    const latestByTrack = new Map<string, LatestRecord>()

    for (const row of rows) {
      const track = row[COL_TRACK]
      const date = row[COL_DATE]
      const timeMs = Number(row[COL_TIME_MS])
      if (!track || !date || Number.isNaN(timeMs)) continue

      const current = latestByTrack.get(track)
      if (!current || date > current.date) {
        latestByTrack.set(track, {
          player: row[COL_PLAYER],
          date,
          timeMs,
          videoUrl: row[COL_VIDEO] || null,
        })
      }
    }

    // 4. Mapear nombre de circuito -> id de tu tabla tracks.
    // Si un circuito del CSV no existe en tu tabla tracks, se ignora
    // y se reporta en notFound (mejor eso que crear filas silenciosamente
    // con nombres que podrian tener variaciones de formato).
    const { data: tracks, error: tracksError } = await supabase
      .from('tracks')
      .select('id, name')

    if (tracksError) throw tracksError

    const trackIdByName = new Map(tracks.map((t) => [t.name, t.id]))

    // 5. Construir las filas a upsertar
    const updates: Array<{
      track_id: number
      player_name: string
      time_ms: number
      record_date: string
      video_url: string | null
      updated_at: string
    }> = []
    const notFound: string[] = []

    for (const [trackName, record] of latestByTrack) {
      const trackId = trackIdByName.get(trackName)
      if (!trackId) {
        notFound.push(trackName)
        continue
      }
      updates.push({
        track_id: trackId,
        player_name: record.player,
        time_ms: record.timeMs,
        record_date: record.date,
        video_url: record.videoUrl,
        updated_at: new Date().toISOString(),
      })
    }

    if (notFound.length > 0) {
      console.warn('Circuitos del CSV sin match en la tabla tracks:', notFound)
    }

    // 6. Upsert en world_records (unique(track_id) hace que sobreescriba)
    const { error: upsertError } = await supabase
      .from('world_records')
      .upsert(updates, { onConflict: 'track_id' })

    if (upsertError) throw upsertError

    return new Response(
      JSON.stringify({ updated: updates.length, notFound }),
      { headers: { 'Content-Type': 'application/json' } },
    )
  } catch (err) {
    console.error(err)
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})