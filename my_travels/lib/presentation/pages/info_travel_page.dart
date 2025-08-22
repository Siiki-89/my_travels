import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:lottie/lottie.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/pages/map_page.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/utils/map_utils.dart';
import 'package:provider/provider.dart';

class InfoTravelPage extends StatelessWidget {
  const InfoTravelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final travel = ModalRoute.of(context)!.settings.arguments as Travel;
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mapProvider.stops.every((s) => s == null)) {
        for (int i = 0; i < travel.stopPoints.length; i++) {
          final stop = travel.stopPoints[i];
          if (stop.latitude != null && stop.longitude != null) {
            mapProvider.setStop(
              i,
              LocationMapModel(
                locationId: stop.id?.toString() ?? stop.locationName,
                description: stop.locationName,
                lat: stop.latitude!,
                long: stop.longitude!,
              ),
            );
          }
        }
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Viagem')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                if (travel.coverImagePath != null &&
                    travel.coverImagePath!.isNotEmpty)
                  Image.file(
                    File(travel.coverImagePath!),
                    fit: BoxFit.cover,
                    height: 300,
                    width: double.infinity,
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        travel.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.check_circle),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.grey[300],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildContainerData(travel.startDate),
                      Lottie.asset(
                        'assets/images/lottie/typelocomotion/airplane.json',
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
                      ),
                      _buildContainerData(travel.endDate),
                    ],
                  ),
                  _buildStopPoint(travel),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Participantes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [Text('Adicionar'), Text('imagem')],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  _buildParticipantsList(travel.travelers),
                  SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trajeto da viagem',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapPage()),
                          );
                        },
                        icon: const Icon(
                          Icons.map,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  _buildPreviewMap(context),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '0 Comentarios',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _buildPreviewMap(BuildContext context) {
    final Completer<gmaps.GoogleMapController> _mapController = Completer();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Consumer<MapProvider>(
            builder: (context, mapProvider, _) {
              final stops = mapProvider.stops
                  .whereType<LocationMapModel>()
                  .toList();
              if (stops.isEmpty) {
                return const Center(child: Text('Não há trajeto para mostrar'));
              }

              final bounds = calculateBounds(stops);

              return gmaps.GoogleMap(
                initialCameraPosition: gmaps.CameraPosition(
                  target: gmaps.LatLng(stops.first.lat, stops.first.long),
                  zoom: 10,
                ),
                markers: stops
                    .map(
                      (s) => gmaps.Marker(
                        markerId: gmaps.MarkerId(s.locationId),
                        position: gmaps.LatLng(s.lat, s.long),
                      ),
                    )
                    .toSet(),
                polylines: {
                  gmaps.Polyline(
                    polylineId: const gmaps.PolylineId('preview_route'),
                    color: Colors.red,
                    width: 3,
                    points: mapProvider.polylinePoints,
                  ),
                },
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                  controller.animateCamera(
                    gmaps.CameraUpdate.newLatLngBounds(bounds, 50),
                  );
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () async {
                final controller = await _mapController.future;
                final stops = context
                    .read<MapProvider>()
                    .stops
                    .whereType<LocationMapModel>()
                    .toList();
                if (stops.isEmpty) return;
                final bounds = calculateBounds(stops);
                controller.animateCamera(
                  gmaps.CameraUpdate.newLatLngBounds(bounds, 50),
                );
              },
              child: const Icon(Icons.center_focus_strong, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Column _buildParticipantsList(List<Traveler> travelers) {
    return Column(
      children: List.generate(travelers.length, (index) {
        final traveler = travelers[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF8A8A8A),
                backgroundImage:
                    traveler.photoPath != null && traveler.photoPath!.isNotEmpty
                    ? FileImage(File(traveler.photoPath!))
                    : null,
                child:
                    (traveler.photoPath == null || traveler.photoPath!.isEmpty)
                    ? const Icon(Icons.person, size: 35, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    traveler.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${traveler.age} anos',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.blue,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ],
          ),
        );
      }),
    );
  }

  Column _buildStopPoint(Travel travel) {
    return Column(
      children: List.generate(travel.stopPoints.length, (index) {
        final stop = travel.stopPoints[index];
        final isLast = index == travel.stopPoints.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: isLast
                      ? const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 24,
                        )
                      : const Icon(
                          Icons.trip_origin,
                          color: Colors.blue,
                          size: 16,
                        ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Icon(Icons.more_vert, size: 16),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  stop.locationName,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Container _buildContainerData(DateTime data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          DateFormat('dd/MM/yyyy').format(data),
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}
