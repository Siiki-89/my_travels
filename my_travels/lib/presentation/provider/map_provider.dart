import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/services/google_maps_service.dart';

/// Manages the state for map-related features, including stops and route polylines.
class MapProvider with ChangeNotifier {
  final GoogleMapsService _googleMapsService;

  /// Creates an instance of [MapProvider].
  MapProvider({required GoogleMapsService googleMapsService})
    : _googleMapsService = googleMapsService;

  // -- State --
  List<LocationMapModel> _stops = [];
  List<LatLng> _polylinePoints = [];
  bool _isLoading = false;
  String? _error;

  // -- Getters --
  /// The list of stops (locations) for the current route.
  List<LocationMapModel> get stops => _stops;

  /// The list of geographical points that form the route polyline.
  List<LatLng> get polylinePoints => _polylinePoints;

  /// Whether the provider is currently fetching route data from the API.
  bool get isLoading => _isLoading;

  /// A message describing the last error that occurred, if any.
  String? get error => _error;

  // -- Route Management --

  /// Creates a new route from a given list of stops.
  Future<void> createRouteFromStops(List<LocationMapModel> newStops) async {
    _stops = newStops;
    await _updateRoute();
  }

  // -- Stop Management --

  /// Adds or updates a stop at the given index and recalculates the route.
  void setStop(int index, LocationMapModel location) {
    if (index >= _stops.length) {
      _stops.add(location);
    } else {
      _stops[index] = location;
    }
    _updateRoute();
  }

  /// Adds an empty stop placeholder.
  /// This stop will not be included in the route until it has a valid location.
  void addEmptyStop() {
    _stops.add(
      LocationMapModel(description: '', locationId: '', lat: 0.0, long: 0.0),
    );
    notifyListeners();
  }

  /// Removes a stop by index and recalculates the route.
  void removeStop(int index) {
    if (index >= 0 && index < _stops.length) {
      _stops.removeAt(index);
      _updateRoute();
    }
  }

  /// Clears all stops and the current route from the map.
  void clearStops() {
    _stops.clear();
    _polylinePoints.clear();
    notifyListeners();
  }

  // -- Internal Helpers --

  /// Central method to calculate and update the polyline by connecting all valid stops.
  Future<void> _updateRoute() async {
    final validStops = _stops
        .where((s) => s.lat != 0.0 && s.long != 0.0)
        .toList();

    // If there are less than 2 stops, there's no route to calculate.
    if (validStops.length < 2) {
      _polylinePoints.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPolylinePoints = <LatLng>[];
      for (var i = 0; i < validStops.length - 1; i++) {
        final origin = LatLng(validStops[i].lat, validStops[i].long);
        final destination = LatLng(
          validStops[i + 1].lat,
          validStops[i + 1].long,
        );

        final routeSegment = await _googleMapsService.getRouteCoordinates(
          origin,
          destination,
        );
        newPolylinePoints.addAll(routeSegment);
      }
      _polylinePoints = newPolylinePoints;
    } catch (e) {
      _error = 'Failed to calculate the route.';
      // debugPrint('Error updating route: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
