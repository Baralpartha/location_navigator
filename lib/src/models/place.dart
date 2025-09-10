class Place {
  final String name;
  final double lat;
  final double lon;
  final String type;
  double? distance; // ইউজার থেকে দূরত্ব (মিটারে)

  Place({
    required this.name,
    required this.lat,
    required this.lon,
    required this.type,
    this.distance,
  });

  factory Place.fromOverpass(Map<String, dynamic> json, String type) {
    double lat = 0, lon = 0;
    if (json["type"] == "node") {
      lat = (json["lat"] as num).toDouble();
      lon = (json["lon"] as num).toDouble();
    } else if (json["center"] != null) {
      lat = (json["center"]["lat"] as num).toDouble();
      lon = (json["center"]["lon"] as num).toDouble();
    }
    final name = json["tags"]?["name"] ?? "Unnamed $type";
    return Place(name: name, lat: lat, lon: lon, type: type);
  }
}
