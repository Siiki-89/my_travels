import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/services/google_maps_service.dart';

class MapProvider with ChangeNotifier {
  MapProvider({required this.googleMapsService});
  final GoogleMapsService googleMapsService;

  List<LocationMapModel> _stops = [];
  List<LocationMapModel> get stops => _stops;

  List<LatLng> _polylinePoints = [];
  List<LatLng> get polylinePoints => _polylinePoints;

  // >> NOVO MÉTODO MAIS EFICIENTE <<
  Future<void> createRouteFromStops(List<LocationMapModel> newStops) async {
    _stops = newStops;
    _polylinePoints = []; // Limpa a rota antiga

    if (newStops.length < 2) {
      notifyListeners();
      return;
    }

    for (var i = 0; i < newStops.length - 1; i++) {
      final origin = LatLng(newStops[i].lat, newStops[i].long);
      final destination = LatLng(newStops[i + 1].lat, newStops[i + 1].long);

      final route = await googleMapsService.getRouteCoordinates(
        origin,
        destination,
      );
      _polylinePoints.addAll(route);
    }
    notifyListeners();
  }

  // O método abaixo ainda é útil para a tela de criação
  void setStop(int index, LocationMapModel location) {
    if (index >= _stops.length) {
      _stops.add(location);
    } else {
      _stops[index] = location;
    }
    _updateRoute(); // Para feedback em tempo real na criação
    notifyListeners();
  }

  void addEmptyStop() {
    _stops.add(
      LocationMapModel(description: '', locationId: '', lat: 0.0, long: 0.0),
    );
    notifyListeners();
  }

  void removeStop(int index) {
    if (index < _stops.length) {
      _stops.removeAt(index);
      _updateRoute();
      notifyListeners();
    }
  }

  void clearStops() {
    _stops = [];
    _polylinePoints = [];
    notifyListeners();
  }

  Future<void> _updateRoute() async {
    _polylinePoints = [];
    final validStops = _stops.whereType<LocationMapModel>().toList();

    if (validStops.length < 2) {
      notifyListeners();
      return;
    }

    for (var i = 0; i < validStops.length - 1; i++) {
      final origin = LatLng(validStops[i].lat, validStops[i].long);
      final destination = LatLng(validStops[i + 1].lat, validStops[i + 1].long);

      final route = await googleMapsService.getRouteCoordinates(
        origin,
        destination,
      );
      _polylinePoints.addAll(route);
    }
    notifyListeners();
  }
}
