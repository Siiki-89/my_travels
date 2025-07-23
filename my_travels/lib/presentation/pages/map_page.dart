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

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<LocationService>(
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

          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: Consumer<MapProvider>(
              builder: (_, provider, __) {
                return Column(
                  children: [
                    const PlaceSearchField(index: 0, hint: 'Local de partida'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
