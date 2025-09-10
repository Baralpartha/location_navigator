/// A class representing a nearby place fetched from Overpass API.
///
/// Contains the name, coordinates, type, and optional distance from the user.
class Place {
  /// The name of the place.
  final String name;

  /// The latitude of the place.
  final double lat;

  /// The longitude of the place.
  final double lon;

  /// The type of the place (amenity), e.g., 'hospital', 'mosque'.
  final String type;

  /// Distance from the user in meters. Calculated at runtime.
  double? distance;

  /// Creates a [Place] with the given [name], [lat], [lon], [type], and optional [distance].
  Place({
    required this.name,
    required this.lat,
    required this.lon,
    required this.type,
    this.distance,
  });

  /// Creates a [Place] from Overpass API JSON.
  ///
  /// The [json] parameter is a single element from the Overpass API response.
  /// The [type] is the amenity type of the place.
  ///
  /// Handles both 'node' type elements and elements with 'center' coordinates.
  /// If the place name is not available in the JSON, it defaults to 'Unnamed $type'.
  factory Place.fromOverpass(Map<String, dynamic> json, String type) {
    double lat = 0, lon = 0;

    if (json['type'] == 'node') {
      lat = (json['lat'] as num).toDouble();
      lon = (json['lon'] as num).toDouble();
    } else if (json['center'] != null) {
      final center = json['center'] as Map<String, dynamic>;
      lat = (center['lat'] as num).toDouble();
      lon = (center['lon'] as num).toDouble();
    }

    final tags = json['tags'] as Map<String, dynamic>?;
    final name = tags?['name'] ?? 'Unnamed $type';

    return Place(name: name, lat: lat, lon: lon, type: type);
  }
}
