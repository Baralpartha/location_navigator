import 'package:flutter_test/flutter_test.dart';
import 'package:location_navigator/location_navigator.dart';

void main() {
  test('NearbyPlacesWidget can be created', () {
    // Basic sanity check
    const widget = NearbyPlacesWidget(); // <-- Add const here
    expect(widget, isA<NearbyPlacesWidget>());
  });
}
