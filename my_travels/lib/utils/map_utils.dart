import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/model/location_map_model.dart';

LatLngBounds calculateBounds(List<LocationMapModel> stops) {
  final southWest = LatLng(
    stops.map((s) => s.lat).reduce((a, b) => a < b ? a : b),
    stops.map((s) => s.long).reduce((a, b) => a < b ? a : b),
  );
  final northEast = LatLng(
    stops.map((s) => s.lat).reduce((a, b) => a > b ? a : b),
    stops.map((s) => s.long).reduce((a, b) => a > b ? a : b),
  );

  return LatLngBounds(southwest: southWest, northeast: northEast);
}

Future<List<LocationMapModel>> getTravelStops(Travel travel) async {
  return travel.stopPoints
      .where((s) => s.latitude != null && s.longitude != null)
      .map(
        (s) => LocationMapModel(
          locationId: s.id?.toString() ?? s.locationName,
          description: s.locationName,
          lat: s.latitude!,
          long: s.longitude!,
        ),
      )
      .toList();
}
