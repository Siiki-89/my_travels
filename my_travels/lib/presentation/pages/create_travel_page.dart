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
              child: Column(
                children: [
                  InkWell(
                    child: Container(
                      child: providerTravel.coverImage == null
                          ? const Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.black,
                            )
                          : null,
                      height:
                          providerTravel.coverImage != null ||
                              providerTravel.coverImage == ''
                          ? 300
                          : 150,
                      width: double.infinity,

                      decoration: providerTravel.coverImage != null
                          ? BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              image: providerTravel.coverImage != null
                                  ? DecorationImage(
                                      image: FileImage(
                                        providerTravel.coverImage!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            )
                          : null,
                    ),
                    onTap: () async {
                      await _cropImage(context, providerTravel);
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Titulo da viagem
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: travelerProvider.titleController,
                          decoration: InputDecoration(
                            labelText: loc.travelAddTitle,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                //Inicio
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.travelAddStart),
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
                                        color: Color(0xff666666),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                //final
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.travelAddFinal),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _selectDate(context, false),
                                    style: ElevatedButton.styleFrom(
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),

                                    child: Text(
                                      providerTravel.finalDateString,
                                      style: TextStyle(
                                        color: Color(0xff666666),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        //Veiculo de locomoção
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text('${loc.travelAddTypeLocomotion}: '),
                            SizedBox(width: 76),
                            Text(
                              providerTravel.transportSelect.label,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SelectTransport(),
                        const SizedBox(height: 10),
                        //Viajantes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.users),
                            IconButton(
                              onPressed: () {
                                context.read<TravelerProvider>().loadTravelers(
                                  context,
                                );

                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return const CreateSelectTravelerDialog();
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFF176FF2),
                              ),
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
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFF176FF2),
                              ),
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
                        Text(loc.travelAddTrip),
                        SizedBox(height: 16),

                        //Local
                        Consumer<MapProvider>(
                          builder: (context, provider, child) {
                            final providerTravel = context
                                .watch<TravelProvider>();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(
                                  providerTravel.destinations.length,
                                  (i) {
                                    final destination =
                                        providerTravel.destinations[i];
                                    final bool isStartPoint = (i == 0);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          // Ícone de origem ou parada
                                          Icon(
                                            isStartPoint
                                                ? Icons.trip_origin
                                                : Icons.pin_drop,
                                            color: isStartPoint
                                                ? Colors.blue
                                                : Colors.red,
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

                                          const SizedBox(width: 8),

                                          // Botão de deletar (mostrado sempre)
                                          IconButton(
                                            onPressed: () {
                                              providerTravel
                                                  .removeDestinationById(
                                                    destination.id,
                                                  );
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.grey,
                                            ),
                                            iconSize: 20,
                                            tooltip: 'Remover destino',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),
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
                                        style: TextStyle(
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        Row(
                          children: [
                            Text('Mostrar mapa'),
                            SizedBox(width: 80),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/mappage');
                              },
                              icon: const Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Color(0xFF176FF2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
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
            );
          },
        ),
      ),
    );
  }

  Future<CroppedFile?> _croppedImage(File image) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    return croppedFile;
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
