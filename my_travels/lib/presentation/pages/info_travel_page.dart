import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/info_travel_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:my_travels/utils/map_utils.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class InfoTravelPage extends StatelessWidget {
  const InfoTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final travelId = ModalRoute.of(context)!.settings.arguments as int?;

    // Dispara a verificação em cada build. O provider vai decidir se busca os dados ou não.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InfoTravelProvider>().fetchTravelDetailsIfNeeded(
        context,
        travelId,
      );
    });

    final provider = context.watch<InfoTravelProvider>();
    final travel = provider.travel;

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (provider.isLoading && travel == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (travel == null) {
              return const Center(child: Text('Nenhuma viagem para exibir.'));
            }
            return Stack(
              children: [
                _InfoTravelView(travel: travel),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: const BackButton(
                          color:
                              Colors.white, // Define a cor do ícone de voltar
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A View principal que exibe os detalhes da viagem.
class _InfoTravelView extends StatelessWidget {
  const _InfoTravelView({required this.travel});
  final Travel travel;

  @override
  Widget build(BuildContext context) {
    final infoProvider = context.watch<InfoTravelProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          const _CarouselView(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travel.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildDateContainer(travel.startDate),
                    if (infoProvider.vehicleModel?.lottieAsset.isNotEmpty ??
                        false)
                      Lottie.asset(
                        infoProvider.vehicleModel!.lottieAsset,
                        width: 50,
                        height: 50,
                      )
                    else if (travel.vehicle != null)
                      Text(travel.vehicle!),
                    _buildDateContainer(travel.endDate),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStopPoints(travel),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Participantes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
                ),
                const SizedBox(height: 8),
                _ParticipantsList(travelers: travel.travelers),
                const SizedBox(height: 6),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trajeto da viagem',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(),
                    ),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/mappage'),
                      child: Lottie.asset(
                        'assets/images/lottie/general/map.json',
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _PreviewMap(),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                const _CommentsView(),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/newcomment',
                        arguments: travel,
                      );
                      if (result == true && context.mounted) {
                        context
                            .read<InfoTravelProvider>()
                            .fetchTravelDetailsIfNeeded(context, travel.id);
                      }
                    },
                    style: AppButtonStyles.primaryButtonStyle,
                    child: const Text(
                      'Adicionar comentario',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateContainer(DateTime date) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        DateFormat('dd/MM/yyyy').format(date),
        style: const TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }

  Widget _buildStopPoints(Travel travel) {
    return Column(
      children: List.generate(travel.stopPoints.length, (index) {
        final stop = travel.stopPoints[index];
        final isLast = index == travel.stopPoints.length - 1;
        return Row(
          children: [
            Column(
              children: [
                Icon(
                  isLast ? Icons.location_on : Icons.trip_origin,
                  color: isLast ? Colors.red : Colors.blue,
                  size: 24,
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
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
}

// Os sub-widgets (_CarouselView, etc.) usam o `context.watch` para se reconstruir
// sempre que o provider notificar uma mudança.

class _ParticipantsList extends StatelessWidget {
  final List<Traveler> travelers;

  const _ParticipantsList({required this.travelers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: travelers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),

      itemBuilder: (context, index) {
        final traveler = travelers[index];

        return Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  traveler.photoPath != null && traveler.photoPath!.isNotEmpty
                  ? FileImage(File(traveler.photoPath!))
                  : null,
              child: traveler.photoPath == null || traveler.photoPath!.isEmpty
                  ? const Icon(Icons.person, size: 35)
                  : null,
            ),
            const SizedBox(width: 16),
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
                if (traveler.age != null)
                  Text(
                    '${traveler.age} anos',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                showSmoothDialog(
                  context,
                  ConfirmationDialog(
                    title: 'Insira imagem a viagem',
                    content: 'As imagens ficarão vinculadas a viagem',
                    confirmText: 'Salvar',
                    cancel: 'Cancelar',
                    onConfirm: () {},
                  ),
                );
              },
              icon: Icon(Icons.add),
            ),
          ],
        );
      },
    );
  }
}

class _CarouselView extends StatelessWidget {
  const _CarouselView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InfoTravelProvider>();
    if (provider.allImagePaths.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Nenhuma imagem para exibir')),
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: provider.allImagePaths.length,
          itemBuilder: (context, index, realIndex) {
            return Image.file(
              File(provider.allImagePaths[index]),
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
          options: CarouselOptions(
            height: 300,
            autoPlay: provider.allImagePaths.length > 1,
            viewportFraction: 1,
            onPageChanged: (index, reason) =>
                provider.setCurrentImageIndex(index),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewMap extends StatelessWidget {
  const _PreviewMap();

  @override
  Widget build(BuildContext context) {
    final mapController = Completer<gmaps.GoogleMapController>();

    return SizedBox(
      height: 200,
      child: Consumer<MapProvider>(
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
              if (!mapController.isCompleted) {
                mapController.complete(controller);
              }
              controller.animateCamera(
                gmaps.CameraUpdate.newLatLngBounds(bounds, 50),
              );
            },
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
          );
        },
      ),
    );
  }
}

class _CommentsView extends StatelessWidget {
  const _CommentsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InfoTravelProvider>();
    final comments = provider.comments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${comments.length} Comentários',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 12),
        if (comments.isEmpty)
          const Text('Nenhum comentário ainda.')
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: comments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Container(
                  width: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          comment.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: comment.traveler?.photoPath != null
                                ? FileImage(File(comment.traveler!.photoPath!))
                                : null,
                            child: comment.traveler?.photoPath == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              comment.traveler?.name ?? 'Anônimo',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
