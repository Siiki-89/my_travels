// In lib/presentation/pages/map_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/utils/map_utils.dart';

/// A page that displays the travel route on a Google Map.
class MapPage extends StatelessWidget {
  /// Creates an instance of [MapPage].
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The controller is created inside the build method in a StatelessWidget.
    final Completer<gmaps.GoogleMapController> controllerCompleter =
        Completer();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapAppBarTitle), centerTitle: true),
      body: Consumer<MapProvider>(
        builder: (context, mapProvider, _) {
          // Filters out stops that don't have a valid location yet.
          final stopsWithLocation = mapProvider.stops
              .where((s) => s.lat != 0.0)
              .toList();

          if (stopsWithLocation.isEmpty) {
            return Center(child: Text(l10n.noRouteToShow));
          }

          final initialLatLng = gmaps.LatLng(
            stopsWithLocation.first.lat,
            stopsWithLocation.first.long,
          );

          return gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: initialLatLng,
              zoom: 12,
            ),
            markers: stopsWithLocation
                .map(
                  (s) => gmaps.Marker(
                    markerId: gmaps.MarkerId(s.locationId),
                    position: gmaps.LatLng(s.lat, s.long),
                    infoWindow: gmaps.InfoWindow(title: s.description),
                  ),
                )
                .toSet(),
            polylines: {
              gmaps.Polyline(
                polylineId: const gmaps.PolylineId('full_route'),
                color: Colors.red,
                width: 4,
                points: mapProvider.polylinePoints,
              ),
            },
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (gmaps.GoogleMapController controller) async {
              if (!controllerCompleter.isCompleted) {
                controllerCompleter.complete(controller);
              }

              // Animate camera to fit all markers once the map is created.
              if (stopsWithLocation.length > 1) {
                final bounds = calculateBounds(stopsWithLocation);
                await controller.animateCamera(
                  gmaps.CameraUpdate.newLatLngBounds(bounds, 50),
                );
              }
            },
          );
        },
      ),
    );
  }
}
