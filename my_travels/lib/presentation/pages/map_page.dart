import 'dart:async';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/utils/map_utils.dart'; // <- utilitário

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final Completer<gmaps.GoogleMapController> _controller = Completer();

    return Scaffold(
      appBar: AppBar(title: Text(loc.mapAppBarTitle), centerTitle: true),
      body: Consumer<MapProvider>(
        builder: (context, mapProvider, _) {
          final stopsWithLocation = mapProvider.stops
              .whereType<LocationMapModel>()
              .toList();

          if (stopsWithLocation.isEmpty) {
            return const Center(child: Text('Não há trajeto para mostrar'));
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
                polylineId: const gmaps.PolylineId('rota_completa'),
                color: Colors.red,
                width: 4,
                points: mapProvider.polylinePoints,
              ),
            },
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (gmaps.GoogleMapController controller) async {
              _controller.complete(controller);

              if (stopsWithLocation.length > 1) {
                final bounds = calculateBounds(stopsWithLocation);
                controller.animateCamera(
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
