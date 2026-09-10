import '../models/track.dart';
import '../supabase_client.dart';

class TracksRepository {
  Future<List<Track>> fetchAll() async {
    final rows = await supabase
        .from('tracks')
        .select()
        .order('track_order', ascending: true);
    return rows.map(Track.fromJson).toList();
  }

  Future<Track> fetchById(int id) async {
    final row = await supabase.from('tracks').select().eq('id', id).single();
    return Track.fromJson(row);
  }
}
