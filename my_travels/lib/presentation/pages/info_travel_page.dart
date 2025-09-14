import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/create_travel_provider.dart';
import 'package:my_travels/presentation/provider/info_travel_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/custom_dropdown.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:my_travels/utils/map_utils.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class InfoTravelPage extends StatelessWidget {
  const InfoTravelPage({super.key});
  static final GlobalKey _mapKey = GlobalKey();

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
                _InfoTravelView(travel: travel, mapKey: _mapKey),
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
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showSmoothDialog(
                              context: context,
                              dialog: ConfirmationDialog(
                                title: 'Deletar Viagem',
                                content:
                                    'Tem certeza que deseja deletar permanentemente a viagem "${travel.title}"?',
                                cancelText: 'Cancelar',
                                confirmText: 'Deletar',

                                onConfirm: () {
                                  // Agora ele chama a ação correta do provider correto.
                                  context
                                      .read<InfoTravelProvider>()
                                      .deleteTravel(context);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  right: 50.0, // afasta um pouco do botão de deletar
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: IconButton(
                          icon: Icon(
                            travel.isFinished
                                ? Icons.picture_as_pdf
                                : Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (travel.isFinished) {
                              // Gera PDF
                              context.read<InfoTravelProvider>().generatePdf(
                                _mapKey,
                                context,
                              );
                            } else {
                              // Abre tela de edição
                              /*Navigator.pushNamed(
                                context,
                                '/editTravel',
                                arguments: travel,
                              );*/
                            }
                          },
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
  const _InfoTravelView({required this.travel, required this.mapKey});
  final Travel travel;
  final GlobalKey mapKey;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título da viagem (ocupa o espaço disponível)
                    Expanded(
                      child: Text(
                        travel.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Switch para marcar como concluída
                    Transform.scale(
                      // Use valores menores que 1.0 para diminuir.
                      // 0.8 é um bom ponto de partida.
                      scale: 0.8,
                      child: Switch(
                        value: travel.isFinished,
                        onChanged: (newValue) {
                          // Chama o método do provider para alterar o status
                          context.read<InfoTravelProvider>().toggleTravelStatus(
                            context,
                            newValue,
                          );
                        },
                      ),
                    ),
                  ],
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
                RepaintBoundary(key: mapKey, child: const _PreviewMap()),
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
                      // ### AQUI ESTÁ A MUDANÇA ###
                      // 1. A navegação agora é 'await' para esperar por um resultado.
                      final result = await Navigator.pushNamed(
                        context,
                        '/newcomment',
                        arguments: travel,
                      );

                      // 2. Se o resultado for 'true' (indicando sucesso),
                      //    pedimos ao provider para recarregar os dados.
                      if (result == true) {
                        context
                            .read<InfoTravelProvider>()
                            .fetchTravelDetailsIfNeeded(
                              context,
                              travel.id!,
                              forceReload: true,
                            );
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
                Text(traveler.name, style: const TextStyle(fontSize: 16)),
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
                  context: context,
                  dialog: const _ConfirmationDialogImage(
                    title: 'Adicionar Novas Fotos',
                    content:
                        'Selecione as fotos da sua galeria para adicionar à viagem.',
                    confirmText: 'Salvar',
                    cancelText: 'Cancelar',
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

class _ImagePickerArea extends StatelessWidget {
  final InfoTravelProvider provider;

  const _ImagePickerArea({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.selectedImagesForComment.isEmpty) {
      // Botão para adicionar imagens quando a lista está vazia
      return InkWell(
        onTap: () => provider.pickImages(),
        child: Container(
          height: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: const Center(
            child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
          ),
        ),
      );
    } else {
      // Lista horizontal de imagens selecionadas
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
              provider.selectedImagesForComment.length +
              1, // +1 para o botão de adicionar
          itemBuilder: (context, index) {
            if (index == provider.selectedImagesForComment.length) {
              // Botão para adicionar mais imagens
              return InkWell(
                onTap: () => provider.pickImages(),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 40, color: Colors.grey),
                ),
              );
            }

            final imageFile = provider.selectedImagesForComment[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => provider.removeImage(imageFile),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
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

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: gmaps.GoogleMap(
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
            ),
          );
        },
      ),
    );
  }
}

class _ConfirmationDialogImage extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;

  const _ConfirmationDialogImage({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InfoTravelProvider>();
    final travel = provider.travel;
    if (travel == null) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final List<DropdownMenuItem<StopPoint?>> dropdownItems = [
      // 2. Adicione um item inicial que representa a opção "Nenhum"
      // O valor dele é 'null', e ele exibe o texto do hint.
      const DropdownMenuItem<StopPoint?>(
        value: null,
        child: Text('Viagem geral'),
      ),
      ...travel.stopPoints.map((sp) {
        return DropdownMenuItem<StopPoint?>(
          value: sp,
          child: Text(sp.locationName, overflow: TextOverflow.ellipsis),
        );
      }),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinha os títulos à esquerda
          children: [
            Center(
              // Centraliza apenas o título principal
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Título para o Dropdown
            Text(
              'Vincular a um local',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // --- AQUI ESTÁ A MUDANÇA ---
            // Substituído o DropdownButton pelo seu widget estilizado e reutilizável
            CustomDropdown<StopPoint?>(
              hintText: 'Geral da viagem (opcional)',
              value: provider.selectedStopPointForComment,
              items: dropdownItems, // <--- Usa a nova lista
              onChanged: (value) => provider.selectStopPoint(value),
            ),

            // --- FIM DA MUDANÇA ---
            const SizedBox(height: 24),
            // Área de seleção de imagens
            _ImagePickerArea(provider: provider),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButtonStyle,
                    onPressed: () {
                      context
                          .read<InfoTravelProvider>()
                          .clearNewCommentFields();
                      Navigator.of(context).pop();
                    },
                    child: Text(cancelText),
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButtonStyle,
                    onPressed: () {
                      provider.saveImagesAsComment(context);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      confirmText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsView extends StatelessWidget {
  const _CommentsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InfoTravelProvider>();

    // --- AQUI ESTÁ A MUDANÇA ---
    // Filtramos a lista para pegar apenas comentários que têm texto.
    // Usamos trim() para remover espaços em branco e garantir que o conteúdo é real.
    final commentsWithContent = provider.comments
        .where((comment) => comment.content.trim().isNotEmpty)
        .toList();
    // --- FIM DA MUDANÇA ---

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // Usamos a contagem da nova lista filtrada
          '${commentsWithContent.length} Comentários',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 12),
        // Verificamos se a nova lista está vazia
        if (commentsWithContent.isEmpty)
          const Text('Nenhum comentário ainda.')
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // Usamos os dados da nova lista filtrada
              itemCount: commentsWithContent.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final comment = commentsWithContent[index];
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
