import 'package:flutter_test/flutter_test.dart';
import 'package:location_navigator/location_navigator.dart';

void main() {
  test('NearbyPlacesWidget can be created', () {
    // Basic sanity check
    final widget = NearbyPlacesWidget();
    expect(widget, isA<NearbyPlacesWidget>());
  });
}
