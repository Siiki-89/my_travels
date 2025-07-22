import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_travels/services/location_service.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  Future<LocationService> _getLocation() async {
    final location = LocationService();
    await location.getLocation();
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> _controller = Completer();

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<LocationService>(
          future: _getLocation(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final location = snapshot.data!;
            final CameraPosition _initialPosition = CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 14,
            );
            return GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
            );
          },
        ),
      ),
    );
  }
}
