import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_navigator/src/place_service.dart';
import 'package:location_navigator/src/screens/map_screen.dart';
import '../location_navigator.dart';

/// A widget that fetches and displays nearby places of interest,
/// such as mosques, hospitals, hotels, restaurants, and pharmacies.
class NearbyPlacesWidget extends StatefulWidget {
  /// The search radius in meters for nearby places. Default is 2000 meters.
  final int radius;

  /// Creates a [NearbyPlacesWidget] with an optional [radius].
  const NearbyPlacesWidget({super.key, this.radius = 2000});

  @override
  State<NearbyPlacesWidget> createState() => _NearbyPlacesWidgetState();
}

class _NearbyPlacesWidgetState extends State<NearbyPlacesWidget> {
  Position? _userPosition;
  List<Place> _places = [];
  bool _loading = false;
  String _selectedAmenity = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final _amenities = {
    'Mosques': 'place_of_worship',
    'Hospitals': 'hospital',
    'Restaurants': 'restaurant',
    'Hotels': 'tourism=hotel',
    'Pharmacies': 'pharmacy',
  };

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

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

      for (var place in results) {
        place.distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          place.lat,
          place.lon,
        );
      }

      List<Place> filtered = results;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        filtered = results
            .where(
              (p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
            .toList();
      }

      filtered.sort((a, b) => a.distance!.compareTo(b.distance!));

      setState(() {
        _places = filtered;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDistance(double distance) {
    if (distance < 1000) return '${distance.toStringAsFixed(0)} m';
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    if (_userPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Dropdown to select place type
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            value: _selectedAmenity.isEmpty ? null : _selectedAmenity,
            hint: const Text('Select Place Type'),
            items: _amenities.entries
                .map(
                  (e) => DropdownMenuItem(
                value: e.value,
                child: Text(e.key),
              ),
            )
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedAmenity = val;
                _searchQuery = '';
                _searchController.clear();
                _places.clear();
              });
              _fetchPlaces();
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),

        // Search box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Search Nearby Place',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.isEmpty) return;
                  setState(() {
                    _selectedAmenity = '';
                    _searchQuery = query;
                    _places.clear();
                  });
                  _fetchPlaces(searchQuery: query);
                },
              ),
            ),
            onSubmitted: (val) {
              final query = val.trim();
              if (query.isEmpty) return;
              setState(() {
                _selectedAmenity = '';
                _searchQuery = query;
                _places.clear();
              });
              _fetchPlaces(searchQuery: query);
            },
          ),
        ),

        // List of results
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _places.isEmpty
              ? const Center(child: Text('No places found.'))
              : ListView.builder(
            itemCount: _places.length,
            itemBuilder: (context, index) {
              final place = _places[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: ListTile(
                  leading:
                  const Icon(Icons.place, color: Colors.teal),
                  title: Text(place.name),
                  subtitle: Text(
                    '${place.type} • ${_formatDistance(place.distance ?? 0)}',
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
