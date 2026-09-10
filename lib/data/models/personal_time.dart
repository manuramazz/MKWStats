import 'build_type.dart';

class PersonalTime {
  final String? id;
  final String userId;
  final int trackId;
  final int timeMs;
  final DateTime recordDate;
  final BuildType buildType;
  final String? videoUrl;

  const PersonalTime({
    this.id,
    required this.userId,
    required this.trackId,
    required this.timeMs,
    required this.recordDate,
    required this.buildType,
    this.videoUrl,
  });

  factory PersonalTime.fromJson(Map<String, dynamic> json) {
    return PersonalTime(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      trackId: json['track_id'] as int,
      timeMs: json['time_ms'] as int,
      recordDate: DateTime.parse(json['record_date'] as String),
      buildType: BuildType.fromValue(json['combo'] as String?),
      videoUrl: json['video_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'track_id': trackId,
      'time_ms': timeMs,
      'record_date': recordDate.toIso8601String().split('T').first,
      'combo': buildType.value,
      'video_url': videoUrl,
    };
  }
}
