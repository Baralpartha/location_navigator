import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_navigator/src/place_service.dart';
import 'package:location_navigator/src/screens/map_screen.dart';

import '../location_navigator.dart';

/// A reusable widget to fetch and display nearby places (e.g. Mosques, Hospitals, Hotels).
///
/// Features:
/// - Get user's current location.
/// - Dropdown to select place type (Amenity).
/// - Search box to filter nearby places by name.
/// - Display list of nearby places sorted by distance.
/// - Navigate to [MapScreen] on item tap.
class NearbyPlacesWidget extends StatefulWidget {
  /// Search radius in meters (default = 2000m).
  final int radius;

  const NearbyPlacesWidget({super.key, this.radius = 2000});

  @override
  State<NearbyPlacesWidget> createState() => _NearbyPlacesWidgetState();
}

class _NearbyPlacesWidgetState extends State<NearbyPlacesWidget> {
  Position? _userPosition;
  List<Place> _places = [];
  bool _loading = false;
  String _selectedAmenity = "";
  String _searchQuery = "";

  // ignore: unused_field
  Place? _selectedPlace;

  /// Supported amenities
  final _amenities = {
    "Mosques": "place_of_worship",
    "Hospitals": "hospital",
    "Restaurants": "restaurant",
    "Hotels": "tourism=hotel",
    "Pharmacies": "pharmacy",
  };

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// Get user’s current location with permission handling
  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    setState(() {
      _userPosition = position;
    });
  }

  /// Fetch nearby places from API based on selected amenity or search query
  Future<void> _fetchPlaces({String? searchQuery}) async {
    if (_userPosition == null) return;

    setState(() => _loading = true);

    try {
      final results = await PlaceService.fetchNearbyPlaces(
        lat: _userPosition!.latitude,
        lon: _userPosition!.longitude,
        amenity: _selectedAmenity,
        radius: widget.radius,
        searchQuery: searchQuery,
      );

      // Calculate distance for each place
      for (var place in results) {
        place.distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          place.lat,
          place.lon,
        );
      }

      // Filter by search query
      List<Place> filtered = results;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filtered = results
            .where((p) =>
            p.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      // Sort by nearest distance
      filtered.sort((a, b) => a.distance!.compareTo(b.distance!));

      setState(() {
        _places = filtered;
        if (filtered.isNotEmpty) {
          _selectedPlace = filtered[0];
        }
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Format distance nicely (e.g. "250 m" or "1.2 km")
  String _formatDistance(double distance) {
    if (distance < 1000) return "${distance.toStringAsFixed(0)} m";
    return "${(distance / 1000).toStringAsFixed(2)} km";
  }

  @override
  Widget build(BuildContext context) {
    if (_userPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        /// Dropdown to select amenity type
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            hint: const Text("Select Place Type"),
            value: _selectedAmenity.isEmpty ? null : _selectedAmenity,
            items: _amenities.entries
                .map((e) => DropdownMenuItem(
              value: e.value,
              child: Text(e.key),
            ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedAmenity = val ?? "";
                _searchQuery = "";
                _searchController.clear();
                _places.clear();
              });
              if (val != null && val.isNotEmpty) {
                _fetchPlaces();
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),

        /// Search box to find nearby places by name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Search Nearby Place",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  setState(() {
                    _selectedAmenity = "";
                    _searchQuery = _searchController.text.trim();
                    _places.clear();
                  });
                  if (_searchQuery.isNotEmpty) {
                    _fetchPlaces(searchQuery: _searchQuery);
                  }
                },
              ),
            ),
            onSubmitted: (val) {
              setState(() {
                _selectedAmenity = "";
                _searchQuery = val.trim();
                _places.clear();
              });
              if (_searchQuery.isNotEmpty) {
                _fetchPlaces(searchQuery: _searchQuery);
              }
            },
          ),
        ),

        /// Results list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _places.isEmpty
              ? const Center(child: Text("No places found."))
              : ListView.builder(
            itemCount: _places.length,
            itemBuilder: (context, index) {
              final place = _places[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                child: ListTile(
                  leading:
                  const Icon(Icons.place, color: Colors.teal),
                  title: Text(place.name),
                  subtitle: Text(
                    "${place.type} • ${_formatDistance(place.distance ?? 0)}",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(
                          userLat: _userPosition!.latitude,
                          userLon: _userPosition!.longitude,
                          places: _places,
                          selectedPlace: place,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
