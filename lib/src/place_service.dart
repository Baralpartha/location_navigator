import 'dart:convert';
import 'package:http/http.dart' as http;

import '../location_navigator.dart';

/// A service class to fetch nearby places from the Overpass API.
///
/// This class provides a static method to query OpenStreetMap (Overpass API)
/// for nearby amenities such as mosques, hospitals, restaurants, hotels, and pharmacies.
class PlaceService {
  /// Fetches a list of nearby [Place] objects.
  ///
  /// Parameters:
  /// - [lat]: The latitude of the user's current location.
  /// - [lon]: The longitude of the user's current location.
  /// - [amenity]: The type of place to search for (e.g., "hospital", "mosque").
  /// - [radius]: Search radius in meters (default is 2000m).
  /// - [searchQuery]: Optional search string to filter places by name.
  ///
  /// Returns a `Future<List<Place>>` containing nearby places matching the criteria.
  /// Throws an `Exception` if the HTTP request fails.
  static Future<List<Place>> fetchNearbyPlaces({
    required double lat,
    required double lon,
    required String amenity,
    int radius = 2000,
    String? searchQuery,
  }) async {
    String filter = "";

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Search by name (case-insensitive)
      filter = '[name~"$searchQuery",i]';
    } else if (amenity.isNotEmpty) {
      // Search by amenity type
      filter = "[amenity=$amenity]";
    }

    // Build Overpass QL query
    final query = '[out:json];node(around:$radius,$lat,$lon)$filter;out;';
    final url = "https://overpass-api.de/api/interpreter?data=$query";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final elements = (data["elements"] as List);
      return elements.map((e) => Place.fromOverpass(e, amenity)).toList();
    } else {
      throw Exception("Failed to load places");
    }
  }
}
