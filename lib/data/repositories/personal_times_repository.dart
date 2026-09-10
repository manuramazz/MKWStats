import '../models/build_type.dart';
import '../models/personal_time.dart';
import '../supabase_client.dart';

class PersonalTimesRepository {
  /// Best (lowest) time per track_id for the given user and build type.
  /// personal_times keeps full history, so the minimum is computed client-side.
  Future<Map<int, int>> fetchBestTimesByTrack({
    required String userId,
    required BuildType buildType,
  }) async {
    final rows = await supabase
        .from('personal_times')
        .select('track_id, time_ms')
        .eq('user_id', userId)
        .eq('combo', buildType.value);

    final bestByTrack = <int, int>{};
    for (final row in rows) {
      final trackId = row['track_id'] as int;
      final timeMs = row['time_ms'] as int;
      final current = bestByTrack[trackId];
      if (current == null || timeMs < current) {
        bestByTrack[trackId] = timeMs;
      }
    }
    return bestByTrack;
  }

  /// Full history for a single track + build type, unsorted (caller decides order).
  Future<List<PersonalTime>> fetchForTrack({
    required String userId,
    required int trackId,
    required BuildType buildType,
  }) async {
    final rows = await supabase
        .from('personal_times')
        .select()
        .eq('user_id', userId)
        .eq('track_id', trackId)
        .eq('combo', buildType.value);

    return rows.map(PersonalTime.fromJson).toList();
  }

  Future<void> insert(PersonalTime personalTime) async {
    await supabase.from('personal_times').insert(personalTime.toInsertJson());
  }
}
