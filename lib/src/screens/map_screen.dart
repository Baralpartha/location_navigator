import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place.dart';

class MapScreen extends StatefulWidget {
  final double userLat;
  final double userLon;
  final List<Place> places;
  final Place selectedPlace;

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
  double? distance; // meters
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

  /// Fetch route from OSRM
  Future<void> _loadRoute() async {
    if (currentLat == null || currentLon == null) return;

    final url =
        "https://router.project-osrm.org/route/v1/foot/$currentLon,$currentLat;${_selectedPlace.lon},${_selectedPlace.lat}?overview=full&geometries=geojson";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);

      if (data["routes"] != null && data["routes"].isNotEmpty) {
        final route = data["routes"][0];
        final coords = (route["geometry"]["coordinates"] as List)
            .map((c) => LatLng(c[1], c[0]))
            .toList();

        setState(() {
          routePoints = coords;
          distance = route["distance"];
        });
      }
    }
  }

  /// Live location updates
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

      _loadRoute(); // route recalc
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
        title: const Text("Nearby Places"),
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
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),

          // Route line
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

          // Markers
          MarkerLayer(
            markers: [
              // User marker
              if (currentLat != null && currentLon != null)
                Marker(
                  width: 45,
                  height: 45,
                  point: LatLng(currentLat!, currentLon!),
                  child: const Icon(Icons.directions_walk,
                      color: Colors.blue, size: 40),
                ),

              // Places
              if (showAll)
                ...widget.places.map(
                  (p) => Marker(
                    width: 60,
                    height: 60,
                    point: LatLng(p.lat, p.lon),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlace = p;
                        });
                        _loadRoute();
                      },
                      child: Tooltip(
                        message: p.name,
                        child: const Icon(Icons.place,
                            color: Colors.green, size: 32),
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
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 36),
                  ),
                ),
            ],
          ),
        ],
      ),

      // Floating button toggle
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => setState(() => showAll = !showAll),
        child: Icon(showAll ? Icons.layers : Icons.place),
      ),

      // Bottom info card (only distance)
      bottomNavigationBar: (distance != null)
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      offset: const Offset(0, -2),
                      blurRadius: 6)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Distance: ${(distance! / 1000).toStringAsFixed(2)} km",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
