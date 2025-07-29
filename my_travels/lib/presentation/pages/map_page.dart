import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/widgets/place_search_field.dart';
import 'package:my_travels/services/geolocator_service.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  Future<LocationService> _getLocation() async {
    final location = LocationService();
    await location.getDeviceLocation();
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> _controller = Completer();

    return Stack(
      children: [
        FutureBuilder<LocationService>(
          future: _getLocation(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final location = snapshot.data!;
            final CameraPosition _initialPosition = CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 14,
            );

            return Consumer<MapProvider>(
              builder: (context, mapProvider, _) {
                final markers = mapProvider.stops
                    .where((stop) => stop != null)
                    .map(
                      (stop) => Marker(
                        markerId: MarkerId(stop!.locationId),
                        position: LatLng(stop.lat, stop.long),
                        infoWindow: InfoWindow(title: stop.description),
                      ),
                    )
                    .toSet();

                return GoogleMap(
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  markers: markers,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('rota'),
                      color: Colors.red,
                      width: 4,
                      points: mapProvider.polylinePoints,
                    ),
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
