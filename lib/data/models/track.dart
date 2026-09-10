class Track {
  final int id;
  final String name;
  final int trackOrder;
  final String? cup;
  final String? trackImg;
  final String? cupImg;

  const Track({
    required this.id,
    required this.name,
    required this.trackOrder,
    this.cup,
    this.trackImg,
    this.cupImg,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int,
      name: json['name'] as String,
      trackOrder: json['track_order'] as int,
      cup: json['cup'] as String?,
      trackImg: json['track_img'] as String?,
      cupImg: json['cup_img'] as String?,
    );
  }
}
