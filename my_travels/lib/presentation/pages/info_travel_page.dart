import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/widgets/custom_dropdown.dart';
import 'package:my_travels/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/info_travel_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:my_travels/utils/map_utils.dart';
import 'package:my_travels/l10n/app_localizations.dart';

/// Main page displaying detailed information about a travel.
/// Fully stateless. Providers handle all state management.
class InfoTravelPage extends StatelessWidget {
  const InfoTravelPage({super.key});
  static final GlobalKey _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final travelId = ModalRoute.of(context)!.settings.arguments as int?;

    // Trigger data fetching after the first frame.
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
            // Loading state
            if (provider.isLoading && travel == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
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

            // No travel available
            if (travel == null) {
              return Center(child: Text(l10n.noTravelToShow));
            }

            // Main content
            return Stack(
              children: [
                _InfoTravelView(travel: travel, mapKey: _mapKey),

                /// Back button
                const Positioned(
                  top: 0.0,
                  left: 0.0,
                  child: _BackButtonWidget(),
                ),

                /// Delete button
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: _DeleteButton(travel: travel),
                ),

                /// Edit or Export PDF button
                Positioned(
                  top: 0.0,
                  right: 50.0,
                  child: _EditOrExportButton(travel: travel, mapKey: _mapKey),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Back button styled inside a CircleAvatar.
class _BackButtonWidget extends StatelessWidget {
  const _BackButtonWidget();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          child: const BackButton(color: Colors.white),
        ),
      ),
    );
  }
}

/// Delete button with confirmation dialog.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.travel});
  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () async {
              final l10n = AppLocalizations.of(context)!;
              final infoProvider = context.read<InfoTravelProvider>();
              final homeProvider = context.read<HomeProvider>();

              final confirmed = await showSmoothDialog<bool>(
                context: context,
                dialog: ConfirmationDialog(
                  title: l10n.deleteTravelTitle,
                  content: l10n.deleteTravelContent(travel.title),
                  confirmText: l10n.deleteButton,
                  cancelText: l10n.cancel,
                  onConfirm: () => Navigator.of(context).pop(true),
                ),
              );

              if (confirmed == true && context.mounted) {
                await infoProvider.deleteTravel(l10n);

                if (context.mounted) {
                  if (infoProvider.deleteSuccess) {
                    homeProvider.fetchTravels(l10n);
                    Navigator.of(context).pop();
                  } else if (infoProvider.errorMessage != null) {
                    showErrorSnackBar(context, infoProvider.errorMessage!);
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Edit (if not finished) or Export PDF (if finished) button.
class _EditOrExportButton extends StatelessWidget {
  const _EditOrExportButton({required this.travel, required this.mapKey});
  final Travel travel;
  final GlobalKey mapKey;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          child: IconButton(
            icon: Icon(
              travel.isFinished ? Icons.picture_as_pdf : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () async {
              final provider = context.read<InfoTravelProvider>();

              await provider.generatePdf(mapKey, context);

              if (context.mounted && provider.errorMessage != null) {
                showErrorSnackBar(context, provider.errorMessage!);
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Main content of the InfoTravelPage displaying travel details.
class _InfoTravelView extends StatelessWidget {
  const _InfoTravelView({required this.travel, required this.mapKey});
  final Travel travel;
  final GlobalKey mapKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final infoProvider = context.watch<InfoTravelProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          const _CarouselView(), // Travel images carousel
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title and completion toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        travel.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: travel.isFinished,
                        onChanged: (newValue) async {
                          final infoProvider = context
                              .read<InfoTravelProvider>();
                          final homeProvider = context.read<HomeProvider>();
                          final l10n = AppLocalizations.of(context)!;

                          await infoProvider.toggleTravelStatus(l10n);

                          if (context.mounted) {
                            if (infoProvider.statusUpdateSuccess) {
                              final message = newValue
                                  ? l10n.travelMarkedAsCompleted
                                  : l10n.travelReopened;
                              showSuccessSnackBar(context, message);
                              homeProvider.fetchTravels(l10n);
                            } else if (infoProvider.errorMessage != null) {
                              showErrorSnackBar(
                                context,
                                infoProvider.errorMessage!,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                /// Dates and optional vehicle animation
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

                /// Stop points
                _buildStopPoints(travel),
                const Divider(),
                const SizedBox(height: 16),

                /// Travelers list
                Text(
                  l10n.participants,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                _ParticipantsList(travelers: travel.travelers),
                const SizedBox(height: 6),
                const Divider(),
                const SizedBox(height: 8),

                /// Map preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.travelRoute,
                      style: Theme.of(context).textTheme.headlineSmall,
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

                /// Comments section
                const _CommentsView(),
                const SizedBox(height: 12),

                /// Add comment button
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
                    child: Text(
                      l10n.addComment,
                      style: const TextStyle(color: Colors.white),
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

  /// Builds a date container
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

  /// Builds the list of stop points
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

/// Participants list widget (Stateless)
class _ParticipantsList extends StatelessWidget {
  final List<Traveler> travelers;

  const _ParticipantsList({required this.travelers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    l10n.yearsOld(traveler.age ?? 0),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                showSmoothDialog(
                  context: context,
                  dialog: _ConfirmationDialogImage(),
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        );
      },
    );
  }
}
// This widget can be placed at the end of `info_travel_page.dart`

/// A dialog for adding new photos as a comment, allowing the user
/// to link them to a specific stop point.
class _ConfirmationDialogImage extends StatelessWidget {
  /// Creates an instance of [_ConfirmationDialogImage].
  const _ConfirmationDialogImage();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InfoTravelProvider>();
    final travel = provider.travel;
    final l10n = AppLocalizations.of(context)!;

    if (travel == null) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final List<DropdownMenuItem<StopPoint?>> dropdownItems = [
      // An initial item representing the "None" or "General" option.
      DropdownMenuItem<StopPoint?>(value: null, child: Text(l10n.generalTrip)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title is centered.
            Center(
              child: Text(
                l10n.addImageCommentTitle, // Using l10n
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.addImageCommentContent, // Using l10n
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Dropdown title
            Text(
              l10n.linkToLocation, // Using l10n
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            CustomDropdown<StopPoint?>(
              hintText: l10n.generalTripOptional, // Using l10n
              value: provider.selectedStopPointForComment,
              items: dropdownItems,
              onChanged: (value) => provider.selectStopPoint(value),
            ),

            const SizedBox(height: 24),
            // Image selection area
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
                    child: Text(
                      l10n.cancelButton,
                      style: TextStyle(color: Colors.white),
                    ), // Using l10n
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButtonStyle,
                    onPressed: () {
                      provider.saveImagesAsComment(l10n);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      l10n.saveButton,
                      style: TextStyle(color: Colors.white),
                    ), // Using l10n
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

class _ImagePickerArea extends StatelessWidget {
  final InfoTravelProvider provider;

  const _ImagePickerArea({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.selectedImagesForComment.isEmpty) {
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
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: provider.selectedImagesForComment.length + 1,
          itemBuilder: (context, index) {
            if (index == provider.selectedImagesForComment.length) {
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

/// Carousel for travel images
class _CarouselView extends StatelessWidget {
  const _CarouselView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final provider = context.watch<InfoTravelProvider>();
    if (provider.allImagePaths.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(child: Text(loc.noImagesToShow)),
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

/// Map preview of travel route
class _PreviewMap extends StatelessWidget {
  const _PreviewMap();

  @override
  Widget build(BuildContext context) {
    final mapController = Completer<gmaps.GoogleMapController>();
    final loc = AppLocalizations.of(context)!;

    return SizedBox(
      height: 200,
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, _) {
          final stops = mapProvider.stops
              .whereType<LocationMapModel>()
              .toList();
          if (stops.isEmpty) {
            return Center(child: Text(loc.noRouteToShow));
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

/// Comments view
class _CommentsView extends StatelessWidget {
  const _CommentsView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final provider = context.watch<InfoTravelProvider>();

    final commentsWithContent = provider.comments
        .where((comment) => comment.content.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.comments(commentsWithContent.length),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 12),
        if (commentsWithContent.isEmpty)
          Text(loc.noCommentsYet)
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
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
                              comment.traveler?.name ?? loc.anonymous,
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
