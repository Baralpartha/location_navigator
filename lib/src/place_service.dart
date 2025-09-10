import 'dart:convert';
import 'package:http/http.dart' as http;

import '../location_navigator.dart';


class PlaceService {
  static Future<List<Place>> fetchNearbyPlaces({
    required double lat,
    required double lon,
    required String amenity,
    int radius = 2000,
    String? searchQuery,
  }) async {
    String filter = "";

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filter = '[name~"$searchQuery",i]';
    } else if (amenity.isNotEmpty) {
      filter = "[amenity=$amenity]";
    }

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
