import '../models/world_record.dart';
import '../supabase_client.dart';

class WorldRecordsRepository {
  Future<List<WorldRecord>> fetchAll() async {
    final rows = await supabase.from('world_records').select();
    return rows.map(WorldRecord.fromJson).toList();
  }

  Future<WorldRecord?> fetchByTrackId(int trackId) async {
    final row = await supabase
        .from('world_records')
        .select()
        .eq('track_id', trackId)
        .maybeSingle();
    return row == null ? null : WorldRecord.fromJson(row);
  }
}
