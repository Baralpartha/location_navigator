import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place.dart';

/// Screen showing a map with the user's location and nearby places.
/// Provides live location updates and routing to a selected place.
class MapScreen extends StatefulWidget {
  /// User's latitude
  final double userLat;

  /// User's longitude
  final double userLon;

  /// List of nearby places
  final List<Place> places;

  /// Selected place to navigate to
  final Place selectedPlace;

  /// Creates a [MapScreen] with required user location, places, and selected place
  const MapScreen({
    super.key,
    required this.userLat,
    required this.userLon,
    required this.places,
    required this.selectedPlace,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool showAll = false;
  late Place _selectedPlace;
  List<LatLng> routePoints = [];
  double? distance;
  double? currentLat;
  double? currentLon;
  late StreamSubscription<Position> _positionStream;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    currentLat = widget.userLat;
    currentLon = widget.userLon;
    _selectedPlace = widget.selectedPlace;
    _loadRoute();
    _startLiveLocation();
  }

  /// Fetches route from OSRM for the selected place
  Future<void> _loadRoute() async {
    if (currentLat == null || currentLon == null) return;

    final url =
        'https://router.project-osrm.org/route/v1/foot/$currentLon,$currentLat;${_selectedPlace.lon},${_selectedPlace.lat}?overview=full&geometries=geojson';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;

      final routes = data['routes'] as List<dynamic>?;
      if (routes != null && routes.isNotEmpty) {
        final route = routes[0] as Map<String, dynamic>;
        final coords = ((route['geometry'] as Map<String, dynamic>)['coordinates'] as List<dynamic>)
            .map((c) => LatLng((c as List<dynamic>)[1] as double, c[0] as double))
            .toList();

        setState(() {
          routePoints = coords;
          distance = route['distance'] as double?;
        });
      }
    }
  }

  /// Subscribes to live location updates
  void _startLiveLocation() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((pos) {
      setState(() {
        currentLat = pos.latitude;
        currentLon = pos.longitude;
      });

      _mapController.move(LatLng(pos.latitude, pos.longitude), 16);

      _loadRoute();
    });
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Places'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 2,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(widget.userLat, widget.userLon),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),

          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 5,
                  color: Colors.teal,
                ),
              ],
            ),

          MarkerLayer(
            markers: [
              if (currentLat != null && currentLon != null)
                Marker(
                  width: 45,
                  height: 45,
                  point: LatLng(currentLat!, currentLon!),
                  child: const Icon(
                    Icons.directions_walk,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),

              if (showAll)
                ...widget.places.map(
                      (p) => Marker(
                    width: 60,
                    height: 60,
                    point: LatLng(p.lat, p.lon),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlace = p);
                        _loadRoute();
                      },
                      child: Tooltip(
                        message: p.name,
                        child: const Icon(
                          Icons.place,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Marker(
                  width: 60,
                  height: 60,
                  point: LatLng(_selectedPlace.lat, _selectedPlace.lon),
                  child: Tooltip(
                    message: _selectedPlace.name,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => setState(() => showAll = !showAll),
        child: Icon(showAll ? Icons.layers : Icons.place),
      ),
      bottomNavigationBar: (distance != null)
          ? Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Distance: ${(distance! / 1000).toStringAsFixed(2)} km',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }
}
