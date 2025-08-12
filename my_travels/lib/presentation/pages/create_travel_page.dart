import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/pages/map_page.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/place_search_field.dart';
import 'package:my_travels/presentation/widgets/select_experience_dialog.dart';
import 'package:my_travels/presentation/widgets/select_transport.dart';
import 'package:my_travels/presentation/widgets/select_traveler_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

final _formKey = GlobalKey<FormState>();

class CreateTravelPage extends StatelessWidget {
  const CreateTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final providerTravel = context.watch<TravelProvider>();
    final travelerProvider = context.read<TravelerProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.add), centerTitle: true),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //Image Trip
                    _buildImagePicker(context, providerTravel),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Titulo da viagem
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: travelerProvider.titleController,
                            validator: (title) => title!.length < 3
                                ? 'pelo menos 3 caracteres'
                                : null,
                            decoration: InputDecoration(
                              labelText: loc.travelAddTitle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(loc.travelAddStartJourneyDateText),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _selectDate(context, true),
                            style: ElevatedButton.styleFrom(
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              providerTravel.startDateString,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          //Veiculo de locomoção
                          const SizedBox(height: 16),
                          _buildAnimatedText(
                            providerTravel.validateVehicle,
                            loc.travelAddTypeLocomotion,
                          ),

                          const SizedBox(height: 16),
                          SelectTransport(),
                          const SizedBox(height: 10),
                          //Viajantes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAnimatedText(
                                providerTravel.validadeTravelers,
                                loc.users,
                              ),
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<TravelerProvider>()
                                      .loadTravelers(context);

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return const CreateSelectTravelerDialog();
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add, color: Colors.blue),
                              ),
                            ],
                          ), //Listagem dos viajantes
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
                          //Pontos de interesse
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(loc.travelAddTypeInterest),
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<TravelProvider>()
                                      .loadAvailableExperiences(context);

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return CreateTravelDialog();
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add, color: Colors.blue),
                              ),
                            ],
                          ), //Listar interesses
                          Consumer<TravelProvider>(
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
                          //Trajeto da viagem
                          SizedBox(height: 16),
                          _buildAnimatedText(
                            providerTravel.validadeRoute,
                            loc.travelAddTrip,
                          ),
                          SizedBox(height: 16),

                          //Local
                          _buildTravelRoute(loc),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Mostrar mapa'),
                              SizedBox(width: 80),
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/mappage');
                                },
                                icon: const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                } else {
                                  return null;
                                }
                                final travelProvider = context
                                    .read<TravelProvider>();
                                final travelerProvider = context
                                    .read<TravelerProvider>();

                                travelProvider.saveTravel(
                                  context,
                                  travelerProvider,
                                );
                              },
                              style: AppButtonStyles.primaryButtonStyle,
                              child: Text(
                                loc.saveButton,
                                style: TextStyle(color: Colors.white),
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

  Consumer<MapProvider> _buildTravelRoute(AppLocalizations loc) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        final providerTravel = context.watch<TravelProvider>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(providerTravel.destinations.length, (i) {
              final destination = providerTravel.destinations[i];
              final bool isStartPoint = (i == 0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Ícone de origem ou parada
                        Icon(
                          isStartPoint ? Icons.trip_origin : Icons.pin_drop,
                          color: isStartPoint ? Colors.blue : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),

                        // Campo de busca expandido
                        Expanded(
                          child: PlaceSearchField(
                            destination: destination,
                            index: i,
                            hint: isStartPoint
                                ? loc.travelAddStartintPoint
                                : '${loc.travelAddFinalPoint} $i',
                          ),
                        ),

                        // Botão de deletar (mostrado sempre)
                        IconButton(
                          onPressed: () {
                            providerTravel.removeDestinationById(
                              destination.id,
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          iconSize: 20,
                          tooltip: 'Remover destino',
                        ),
                      ],
                    ),
                    if (i < providerTravel.destinations.length - 1)
                      const Icon(Icons.more_vert, size: 16),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),
            if (providerTravel.editingIndex == null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.addEmptyStop();
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

  AnimatedDefaultTextStyle _buildAnimatedText(bool providerType, String loc) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 16,
        color: providerType ? Colors.red : Colors.black,
      ),
      child: Text('${loc}: '),
    );
  }

  InkWell _buildImagePicker(
    BuildContext context,
    TravelProvider providerTravel,
  ) {
    return InkWell(
      onTap: () async {
        await _cropImage(context, providerTravel);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: providerTravel.coverImage != null ? 300 : 150,
        width: double.infinity,
        decoration: providerTravel.coverImage != null
            ? BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: DecorationImage(
                  image: FileImage(providerTravel.coverImage!),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(color: Colors.transparent),
        child: providerTravel.coverImage == null
            ? Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.add_a_photo,
                    key: ValueKey(providerTravel.validateImage),
                    size: 48,
                    color: providerTravel.validateImage
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Future<void> _cropImage(BuildContext context, TravelProvider provider) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      return;
    }

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          showCropGrid: false,
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: true,
        ),
      ],
    );
    provider.setImage(File(croppedFile?.path ?? ''));
  }

  // Coloque este novo método na sua classe de Widget (Page)
  Widget _buildVehicleSelector(TravelProvider provider) {
    return Container(
      height: 100, // Altura fixa para a área de seleção
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.availableTransport.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final transport = provider.availableTransport[index];
          final bool isSelected = provider.isSelectedVehicle(transport);

          return GestureDetector(
            onTap: () => provider.selectVehicle(transport),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  // Destaque visual para o item selecionado
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Lottie.asset(
                      transport.lottieAsset,
                      // 'animate: false' previne que todas as animações toquem ao mesmo tempo.
                      // Elas ficarão estáticas, como ícones.
                      animate: false,
                      width: 60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transport.label,
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
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final provider = context.read<TravelProvider>();

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

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
