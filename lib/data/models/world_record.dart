class WorldRecord {
  final int id;
  final int trackId;
  final String playerName;
  final int timeMs;
  final DateTime recordDate;
  final String? videoUrl;
  final String? character;
  final String? kart;

  const WorldRecord({
    required this.id,
    required this.trackId,
    required this.playerName,
    required this.timeMs,
    required this.recordDate,
    this.videoUrl,
    this.character,
    this.kart,
  });

  factory WorldRecord.fromJson(Map<String, dynamic> json) {
    return WorldRecord(
      id: json['id'] as int,
      trackId: json['track_id'] as int,
      playerName: json['player_name'] as String,
      timeMs: json['time_ms'] as int,
      recordDate: DateTime.parse(json['record_date'] as String),
      videoUrl: json['video_url'] as String?,
      character: json['character'] as String?,
      kart: json['kart'] as String?,
    );
  }
}
