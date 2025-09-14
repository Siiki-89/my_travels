// In lib/presentation/pages/create_travel_page.dart

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/model/experience_model.dart';
import 'package:my_travels/presentation/provider/create_travel_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/custom_text_form_field.dart';
import 'package:my_travels/presentation/widgets/place_search_field.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';

// The form key is managed here for the entire page's form.
final _formKey = GlobalKey<FormState>();

/// A page for creating a new travel itinerary.
class CreateTravelPage extends StatelessWidget {
  /// Creates an instance of [CreateTravelPage].
  const CreateTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final createTravelProvider = context.watch<CreateTravelProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.add),
        centerTitle: true,
        actions: [_buildClearButton(context, l10n)],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Calls the private widget for the image picker/cropper.
                    Consumer<CreateTravelProvider>(
                      builder: (context, provider, _) {
                        return _CropImageButton(provider: provider);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Travel Title
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            labelText: l10n.travelAddTitle,
                            controller: createTravelProvider.titleController,
                            maxLength:
                                50, // <-- 1. Limite visual e de digitação na UI
                            validator: (title) {
                              // A validação agora cobre os dois casos
                              if (title == null || title.trim().length < 3) {
                                return l10n.titleMinLengthError;
                              }
                              if (title.trim().length > 50) {
                                return l10n
                                    .titleMaxLengthError; // <-- 2. Validação da regra de negócio
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(l10n.travelAddStartJourneyDateText),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _selectDate(context, true),
                            style: ElevatedButton.styleFrom(
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              createTravelProvider.startDateString,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Vehicle
                          const SizedBox(height: 16),
                          _AnimatedValidationText(
                            hasError: createTravelProvider.showVehicleError,
                            text: l10n.travelAddTypeLocomotion,
                          ),
                          const SizedBox(height: 16),
                          const _SelectTransport(),
                          const SizedBox(height: 10),

                          // Travelers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _AnimatedValidationText(
                                hasError:
                                    createTravelProvider.showTravelersError,
                                text: l10n.users,
                              ),
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<TravelerProvider>()
                                      .loadTravelers(l10n);
                                  showSmoothDialog(
                                    context: context,
                                    dialog: const _SelectTravelerDialog(),
                                  );
                                },
                                icon: const Icon(Icons.add, color: Colors.blue),
                              ),
                            ],
                          ),
                          Consumer<TravelerProvider>(
                            builder: (context, provider, child) {
                              if (provider.selectedTravelers.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  children: provider.selectedTravelers.map((
                                    traveler,
                                  ) {
                                    return Chip(
                                      label: Text(traveler.name),
                                      onDeleted: () {
                                        provider.toggleTraveler(traveler);
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),

                          // Points of Interest
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.travelAddTypeInterest),
                              // IconButton para Pontos de Interesse (Versão Nova)
                              IconButton(
                                onPressed: () {
                                  showSmoothDialog(
                                    context: context,
                                    dialog: const _SelectExperienceDialog(),
                                  );
                                },
                                icon: const Icon(Icons.add, color: Colors.blue),
                              ),
                            ],
                          ),
                          Consumer<CreateTravelProvider>(
                            builder: (context, provider, child) {
                              if (provider.selectedExperiences.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  children: provider.selectedExperiences.map((
                                    experience,
                                  ) {
                                    return Chip(
                                      label: Text(experience.label),
                                      onDeleted: () {
                                        provider.toggleExperience(experience);
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),

                          // Travel Route
                          const SizedBox(height: 16),
                          _AnimatedValidationText(
                            hasError: createTravelProvider.showRouteError,
                            text: l10n.travelAddTrip,
                          ),
                          const SizedBox(height: 16),

                          // Calls the private widget for the route.
                          _TravelRouteSection(l10n: l10n),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.showMap),
                              const SizedBox(width: 80),
                              InkWell(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/mappage'),
                                child: Lottie.asset(
                                  'assets/images/lottie/general/pin_marker.json',
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!(_formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                // Pega as instâncias necessárias. `read` é para chamar ações.
                                final createTravelProvider = context
                                    .read<CreateTravelProvider>();
                                final travelerProvider = context
                                    .read<TravelerProvider>();
                                final homeProvider = context
                                    .read<HomeProvider>();
                                final l10n = AppLocalizations.of(context)!;

                                // 1. Chama a ação no provider
                                await createTravelProvider.saveTravel(
                                  travelerProvider,
                                  homeProvider,
                                  l10n,
                                );

                                // 2. APÓS a ação, a UI verifica o estado do provider e reage
                                if (context.mounted) {
                                  if (createTravelProvider.saveSuccess) {
                                    // Se teve sucesso, a UI mostra o feedback!
                                    showSuccessSnackBar(
                                      context,
                                      l10n.travelSavedSuccess,
                                    );
                                    Navigator.of(context).pop();
                                  } else if (createTravelProvider
                                          .errorMessage !=
                                      null) {
                                    // Se teve erro, a UI mostra o feedback!
                                    showErrorSnackBar(
                                      context,
                                      createTravelProvider.errorMessage!,
                                    );
                                  }
                                }
                              },
                              style: AppButtonStyles.primaryButtonStyle,
                              child: Text(
                                l10n.saveButton,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the clear form button for the AppBar.
  IconButton _buildClearButton(BuildContext context, AppLocalizations l10n) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        showSmoothDialog(
          context: context,
          dialog: ConfirmationDialog(
            title: l10n.clearFormTitle,
            content: l10n.clearFormContent,
            confirmText: l10n.clearFormConfirm,
            cancelText: l10n.cancel,
            onConfirm: () {
              // The logic to clear the form goes here.
              final travelerProvider = context.read<TravelerProvider>();
              context.read<CreateTravelProvider>().resetForm(travelerProvider);
            },
          ),
        );
      },
    );
  }

  /// Shows a DatePicker to select the start or end date of the travel.
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final provider = context.read<CreateTravelProvider>();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? provider.startDate : provider.endDate,
      firstDate: isStartDate ? DateTime(2020) : provider.startDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      provider.updateDate(pickedDate, isStartDate: isStartDate);
    }
  }
}

// -- PRIVATE WIDGETS (INTERNAL COMPONENTS OF THE PAGE) --

/// A private widget for the image picker with crop functionality.
class _CropImageButton extends StatelessWidget {
  final CreateTravelProvider provider;

  const _CropImageButton({required this.provider});

  Future<void> _cropImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          showCropGrid: false,
          toolbarTitle: l10n.cropperToolbarTitle,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: true,
        ),
      ],
    );

    if (croppedFile == null) return;
    provider.setImage(File(croppedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return _TravelImagePicker(
      providerTravel: provider,
      onTap: () => _cropImage(context),
    );
  }
}

/// A private widget that displays the travel cover image picker.
class _TravelImagePicker extends StatelessWidget {
  final CreateTravelProvider providerTravel;
  final VoidCallback onTap;

  const _TravelImagePicker({required this.providerTravel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasError = providerTravel.showImageError;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: providerTravel.coverImage != null ? 300 : 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: providerTravel.coverImage != null
                  ? const BorderRadius.vertical(bottom: Radius.circular(8))
                  : null,
              border: Border.all(
                color: hasError ? Colors.red : Colors.transparent,
                width: hasError ? 2.0 : 1.0,
              ),
              image: providerTravel.coverImage != null
                  ? DecorationImage(
                      image: FileImage(providerTravel.coverImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: providerTravel.coverImage == null
                ? Center(
                    child: Lottie.asset(
                      'assets/images/lottie/general/camera.json',
                    ),
                  )
                : null,
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              l10n.errorSelectCoverImage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

/// A private dialog for selecting experiences.
class _SelectExperienceDialog extends StatelessWidget {
  const _SelectExperienceDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Dialog(
      shadowColor: Colors.black87,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.experienceTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: Consumer<CreateTravelProvider>(
                builder: (context, provider, child) {
                  // Load experiences only if list is empty
                  if (provider.availableExperiences.isEmpty) {
                    provider.loadAvailableExperiences(context);
                  }

                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: provider.availableExperiences.map((experience) {
                        final bool isSelected = provider.isSelectedExperience(
                          experience,
                        );

                        return GestureDetector(
                          onTap: () => provider.toggleExperience(experience),
                          child: SizedBox(
                            width: (size.width / 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: isSelected ? 3 : 1.0,
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(experience.image),
                                          fit: BoxFit.cover,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    experience.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButtonStyle,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.saveButton,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A private dialog for selecting travelers.
class _SelectTravelerDialog extends StatelessWidget {
  const _SelectTravelerDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Dialog(
        shadowColor: Colors.black87,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.travelerToTravelTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Consumer<TravelerProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (provider.errorMessage != null) {
                    return Center(child: Text(provider.errorMessage!));
                  }
                  if (provider.travelers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_off_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noTravelerFound,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(l10n.registerTraveler),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/travelers');
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: provider.travelers.map((traveler) {
                              final bool isSelected = provider.isSelected(
                                traveler,
                              );
                              return GestureDetector(
                                onTap: () => provider.toggleTraveler(traveler),
                                child: SizedBox(
                                  width: (size.width / 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.transparent,
                                                width: isSelected ? 3 : 1.0,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage:
                                                  traveler.photoPath != null
                                                  ? FileImage(
                                                      File(traveler.photoPath!),
                                                    )
                                                  : null,
                                              child: traveler.photoPath == null
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: Colors.black,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        traveler.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppButtonStyles.primaryButtonStyle,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.saveButton),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A private widget for displaying the list of transport options.
class _SelectTransport extends StatelessWidget {
  const _SelectTransport();

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTravelProvider>(
      builder: (context, provider, _) {
        provider.loadAvailableVehicles(context);
        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.availableTransports.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final transport = provider.availableTransports[index];
              final bool isSelected = provider.isSelectedVehicle(transport);

              return GestureDetector(
                onTap: () => provider.selectVehicle(transport),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Lottie.asset(
                        transport.lottieAsset,
                        key: ValueKey(isSelected),
                        animate: isSelected,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transport.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue : null,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A private widget for displaying the travel route section.
class _TravelRouteSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _TravelRouteSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        final providerTravel = context.watch<CreateTravelProvider>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: providerTravel.destinations.length,
              itemBuilder: (context, index) {
                final destination = providerTravel.destinations[index];
                final bool isStartPoint = (index == 0);

                return Padding(
                  key: ValueKey(destination.id),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isStartPoint ? Icons.trip_origin : Icons.pin_drop,
                            color: isStartPoint ? Colors.blue : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PlaceSearchField(
                              destination: destination,
                              index: index,
                              hint: isStartPoint
                                  ? l10n.travelAddStartintPoint
                                  : '${l10n.travelAddFinalPoint} $index',
                            ),
                          ),
                          if (!isStartPoint)
                            IconButton(
                              onPressed: () => providerTravel
                                  .removeDestinationById(destination.id),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              iconSize: 20,
                              tooltip: l10n.removeDestinationTooltip,
                            ),
                        ],
                      ),
                      if (index < providerTravel.destinations.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.more_vert, size: 16),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            if (providerTravel.editingIndex == null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    mapProvider.addEmptyStop();
                    providerTravel.addDestination();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addDestination),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A component to display a text that changes color based on an error state.
class _AnimatedValidationText extends StatelessWidget {
  final bool hasError;
  final String text;

  const _AnimatedValidationText({required this.hasError, required this.text});

  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).colorScheme?.onSurfaceVariant;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 16,
        color: hasError ? Colors.red.shade700 : defaultColor,
      ),
      child: Text('$text:'),
    );
  }
}
