# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MKWStats: a Flutter mobile app (Android primary; web scaffold present) backed by Supabase for tracking personal time-trial times per track in Mario Kart World and comparing them against current world records. UI strings and code comments are in Spanish.

## Commands

Supabase credentials are injected at compile time via `--dart-define`; copy `env.json.example` to `env.json` (gitignored) and fill `SUPABASE_URL` / `SUPABASE_ANON_KEY`.

```sh
flutter pub get
flutter run --dart-define-from-file=env.json
flutter build apk --dart-define-from-file=env.json
flutter analyze                     # lints: flutter_lints (analysis_options.yaml)
dart format lib
dart run flutter_launcher_icons     # regenerate app icon from assets/icon/icon.jpg
```

There is no `test/` directory yet. If tests are added: `flutter test` / `flutter test path/to/file_test.dart` / `flutter test --plain-name "name"`.

Supabase (CLI, project config in `supabase/config.toml`):

```sh
supabase db pull                    # produces *_remote_schema.sql migrations
supabase migration new <name>
supabase db push
supabase functions deploy fetch-world-records
supabase functions serve fetch-world-records   # local
```

## Architecture

**Layers** (`lib/`):
- `data/` — `supabase_client.dart` exposes a global `supabase` getter (`Supabase.instance.client`). Repositories are plain classes instantiated directly by screens (no DI; `provider` is a dependency but currently unused). Models have hand-written `fromJson` (snake_case DB columns → camelCase fields).
- `features/<feature>/` — one screen per feature plus its `widgets/`. State is local `StatefulWidget` + `setState`; screens call repositories directly.
- `core/` — theme (`AppColors`, `AppTextStyles`, `AppTheme`), shared widgets, and utils (`time_format.dart` for `time_ms` ↔ display string, `improvement_color.dart`).
- `routing/app_router.dart` — single global `GoRouter`. Redirect guards on `supabase.auth.currentSession` and refreshes on `onAuthStateChange`, so sign-in/sign-out navigation happens automatically. `BuildType` is passed between routes via `extra`; `/register` pops a `BuildType` back to the caller, which reloads its data after `push` returns.

**Auth model**: username + password only. `AuthRepository` maps usernames to fake emails `<username>@mkwstats.local` for Supabase Auth and passes `username` in user metadata. A DB trigger `handle_new_user()` creates the `profiles` row. `is_username_taken` is a `security definer` RPC callable by `anon` (used before sign-up).

**BuildType / "combo"**: every personal time belongs to a build type (`optimal` | `meta`), stored as `personal_times.combo` (text). Most views are filtered by the currently selected build type.

**Database** (`public` schema, RLS enabled everywhere):
- `tracks` (read-all; ordered by `track_order`; `track_img`/`cup_img` are filenames resolved locally as `assets/tracks/<file>` / `assets/cups/<file>` via `AssetImageOrFallback`, not URLs).
- `world_records` (read-all; one row per `track_id`).
- `personal_times` (own rows only; full history kept — "best time" is computed client-side as the min per track).
- `profiles`, `online_sessions` (own rows only; online feature is a placeholder screen).

**World records sync**: the Deno edge function `supabase/functions/fetch-world-records/index.ts` downloads `mkwrs.com/data/mkworld_wrs.csv` (full progression history, no header, columns accessed by index constants), keeps the latest entry per track, maps track name → `tracks.id` by exact name match (unmatched names are reported, not inserted), and upserts into `world_records` on `track_id` using the service-role key. `pg_cron` is enabled to schedule it.

**Migrations**: most schema in `supabase/migrations/` comes from `supabase db pull` (`*_remote_schema.sql`); the remote project is the source of truth and was edited via dashboard. Some migration files are empty placeholders. When changing schema, add a migration rather than relying on dashboard edits.
