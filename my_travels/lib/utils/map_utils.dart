// In lib/utils/map_utils.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/model/location_map_model.dart';

/// Calculates the smallest bounding box that contains all given stops.
///
/// This is used to frame the map camera to show the entire route.
/// Handles empty lists safely by returning a default bounding box.
LatLngBounds calculateBounds(List<LocationMapModel> stops) {
  // Critical safety check: .reduce() on an empty list throws an error.
  if (stops.isEmpty) {
    // Return a default bounds if there are no stops to display.
    const defaultLocation = LatLng(0, 0);
    return LatLngBounds(southwest: defaultLocation, northeast: defaultLocation);
  }

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

/// Extracts a list of [LocationMapModel] from a [Travel] entity.
///
/// Filters out stop points that do not have valid coordinates.
List<LocationMapModel> getTravelStops(Travel travel) {
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
