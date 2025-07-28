import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/services/google_maps_service.dart';

class MapProvider extends ChangeNotifier {
  final _service = GoogleMapsService();

  final List<LocationMapModel?> _stops = [null, null];
  List<LocationMapModel?> get stops => _stops;

  // final List<LatLng> _polylinePoints = [];
  // List<LatLng> get polylinePoints => _polylinePoints;

  void setStop(int index, LocationMapModel location) {
    if (index >= _stops.length) {
      _stops.add(location);
    } else {
      _stops[index] = location;
    }
    //_updateRoute();
    notifyListeners();
  }

  void addEmptyStop() {
    _stops.add(null);
    notifyListeners();
  }

  /*
  Future<void> _updateRoute() async {
    _polylinePoints.clear();

    final validStops = _stops.whereType<LocationMapModel>().toList();

    if (validStops.length < 2) return;

    for (int i = 0; i < validStops.length - 1; i++) {
      final origin = LatLng(validStops[i].lat, validStops[i].long);
      final destination = LatLng(validStops[i + 1].lat, validStops[i + 1].long);

      final route = await _service.getRouteCoordinates(origin, destination);
      _polylinePoints.addAll(route);
    }

    notifyListeners();
  }
  */
}
