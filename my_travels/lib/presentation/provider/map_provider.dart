import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/services/google_maps_service.dart';

class MapProvider extends ChangeNotifier {
  final _service = GoogleMapsService();

  final List<Marker> markers = [];

  final List<LocationMapModel?> _stops = [null, null];
  List<LocationMapModel?> get stops => _stops;

  void setStop(int index, LocationMapModel location) {
    if (index >= _stops.length) {
      _stops.add(location);
    } else {
      _stops[index] = location;
    }
    notifyListeners();
  }

  void addEmptyStop() {
    _stops.add(null);
    notifyListeners();
  }
}
