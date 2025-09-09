import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/create_travel_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/custom_text_form_field.dart';
import 'package:my_travels/presentation/widgets/place_search_field.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

final _formKey = GlobalKey<FormState>();

// =======================================================
// WIDGET DA PÁGINA PRINCIPAL
// =======================================================

class CreateTravelPage extends StatelessWidget {
  const CreateTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final createTravelProvider = context.watch<CreateTravelProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.add),
        centerTitle: true,
        actions: [_buildButtonClean(context, appLocalizations)],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Chamada ao novo widget privado para a imagem
                    Consumer<CreateTravelProvider>(
                      builder: (context, providerTravel, _) {
                        return _CropImageButton(provider: providerTravel);
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titulo da viagem
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            labelText: appLocalizations.travelAddTitle,
                            controller: createTravelProvider.titleController,
                            validator: (title) => title!.length < 3
                                ? 'pelo menos 3 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(appLocalizations.travelAddStartJourneyDateText),
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

                          // Veiculo de locomoção
                          const SizedBox(height: 16),
                          _AnimatedValidationText(
                            hasError: createTravelProvider.validateVehicle,
                            text: appLocalizations.travelAddTypeLocomotion,
                          ),
                          const SizedBox(height: 16),
                          const _SelectTransport(),
                          const SizedBox(height: 10),

                          // Viajantes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _AnimatedValidationText(
                                hasError:
                                    createTravelProvider.validateTravelers,
                                text: appLocalizations.users,
                              ),
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<TravelerProvider>()
                                      .loadTravelers(context);
                                  showSmoothDialog(
                                    context,
                                    const _SelectTravelerDialog(),
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
                                    travelers,
                                  ) {
                                    return Chip(
                                      label: Text(travelers.name),
                                      onDeleted: () {
                                        provider.toggleTraveler(travelers);
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),

                          // Pontos de interesse
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(appLocalizations.travelAddTypeInterest),
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<CreateTravelProvider>()
                                      .loadAvailableExperiences(context);
                                  showSmoothDialog(
                                    context,
                                    const _SelectExperienceDialog(),
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

                          // Trajeto da viagem
                          const SizedBox(height: 16),
                          _AnimatedValidationText(
                            hasError: createTravelProvider.validateRoute,
                            text: appLocalizations.travelAddTrip,
                          ),
                          const SizedBox(height: 16),

                          // Chamada ao novo widget privado para a rota
                          _TravelRouteSection(loc: appLocalizations),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Mostrar mapa'),
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
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                final travelerProvider = context
                                    .read<TravelerProvider>();
                                createTravelProvider.saveTravel(
                                  context,
                                  travelerProvider,
                                );
                              },
                              style: AppButtonStyles.primaryButtonStyle,
                              child: Text(
                                appLocalizations.saveButton,
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

  IconButton _buildButtonClean(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return IconButton(
      icon: const Icon(Icons.refresh), // Um ícone mais apropriado que delete
      onPressed: () {
        showSmoothDialog(
          context,
          ConfirmationDialog(
            title: appLocalizations.clearFormTitle,
            content: appLocalizations.clearFormContent,
            confirmText: appLocalizations.clearFormConfirm,
            cancel: appLocalizations.cancel,

            onConfirm: () {
              // Sua lógica para limpar o formulário vai aqui
              final travelerProvider = context.read<TravelerProvider>();
              context.read<CreateTravelProvider>().resetTravelForm(
                travelerProvider,
              );
            },
          ),
        );
      },
    );
  }

  // --- MÉTODOS DE LÓGICA MANTIDOS NA PÁGINA ---

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final provider = context.read<CreateTravelProvider>();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? provider.startData : provider.finalData,
      firstDate: isStartDate ? DateTime(2020) : provider.startData,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      provider.updateDate(pickedDate, isStartDate);
    }
  }
}

// =======================================================
// WIDGETS PRIVADOS (COMPONENTES INTERNOS DA PÁGINA)
// =======================================================
class _CropImageButton extends StatelessWidget {
  final CreateTravelProvider provider;

  const _CropImageButton({required this.provider});

  Future<void> _cropImage(BuildContext context) async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.pink),
    );
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
          toolbarTitle: 'Recortar imagem',
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

class _SelectExperienceDialog extends StatelessWidget {
  const _SelectExperienceDialog();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Dialog(
      shadowColor: Colors.black87,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        // A Column principal "encolhe" para se ajustar ao conteúdo.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appLocalizations.experienceTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // A Column interna organiza a lista rolável e o botão.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flexible permite que a lista cresça e se torne rolável sem erro.
                Flexible(
                  child: Consumer<CreateTravelProvider>(
                    builder: (context, provider, child) {
                      // Se não houver experiências, o Wrap simplesmente não renderiza filhos
                      // e o Dialog ficará pequeno, o que está correto.
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          children: provider.availableExperiences.map((
                            experience,
                          ) {
                            final bool isSelected = provider
                                .isSelectedExperience(experience);
                            // --- CÓDIGO DO CARD IDÊNTICO AO SEU ORIGINAL ---
                            return GestureDetector(
                              onTap: () =>
                                  provider.toggleExperience(experience),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              width: isSelected ? 3 : 1.0,
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                experience.image,
                                              ),
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
                            // --- FIM DO CÓDIGO DO CARD ORIGINAL ---
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
                      appLocalizations.saveButton,
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

class _SelectTravelerDialog extends StatelessWidget {
  const _SelectTravelerDialog();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
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
              appLocalizations.travelerToTravelTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        const Text(
                          'Nenhum viajante encontrado.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Cadastrar Viajante'),
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
                            // --- CÓDIGO DO CARD IDÊNTICO AO SEU ORIGINAL ---
                            return GestureDetector(
                              onTap: () => provider.toggleTraveler(traveler),
                              child: Container(
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
                            // --- FIM DO CÓDIGO DO CARD ORIGINAL ---
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
                        child: Text(
                          appLocalizations.saveButton,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectTransport extends StatelessWidget {
  const _SelectTransport();

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTravelProvider>(
      builder: (context, provider, _) {
        provider.loadAvailableVehicles(context);

        return Container(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.availableTransport.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final transport = provider.availableTransport[index];
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
                        color: isSelected ? Colors.blue : Colors.transparent,
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

class _TravelImagePicker extends StatelessWidget {
  final CreateTravelProvider providerTravel;
  final VoidCallback onTap;

  const _TravelImagePicker({required this.providerTravel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasError = providerTravel.validateImage;

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
                width: hasError ? 3.0 : 1.0,
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
              'Por favor, selecione uma imagem de capa.',
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

/// Componente para exibir a lista de destinos da viagem.
class _TravelRouteSection extends StatelessWidget {
  final AppLocalizations loc;

  const _TravelRouteSection({required this.loc});

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
                                  ? loc.travelAddStartintPoint
                                  : '${loc.travelAddFinalPoint} $index',
                            ),
                          ),
                          IconButton(
                            onPressed: () => providerTravel
                                .removeDestinationById(destination.id),
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            iconSize: 20,
                            tooltip: 'Remover destino',
                          ),
                        ],
                      ),
                      if (index < providerTravel.destinations.length - 1)
                        const Icon(Icons.more_vert, size: 16),
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
                  label: const Text(
                    'Adicionar destino',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Componente para exibir um texto que muda de cor com base em um estado de erro.
class _AnimatedValidationText extends StatelessWidget {
  final bool hasError;
  final String text;

  const _AnimatedValidationText({required this.hasError, required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 600),
      style: TextStyle(
        fontSize: 16,
        color: hasError
            ? Colors.red
            : Theme.of(context).textTheme.bodyMedium?.color,
      ),
      child: Text('$text: '),
    );
  }
}
