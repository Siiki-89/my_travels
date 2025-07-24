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
import 'package:my_travels/services/geolocator_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Titulo da viagem
                  Text(loc.travelAddTitle),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: travelerProvider.titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),

                      hintText: '  ...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.travelAddFinal),
                            ElevatedButton(
                              onPressed: () => _selectDate(context, false),
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
                              return const CreateTravelerDialog();
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down_outlined,
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
                          children: provider.selectedTravelers.map((travelers) {
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
                          Icons.arrow_drop_down_outlined,
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
                  Text('Trajeto da viagem'),
                  SizedBox(height: 16),
                  //Local de partida
                  Consumer<MapProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: const PlaceSearchField(
                                  index: 0,
                                  hint: 'Local de partida',
                                ),
                              ),
                            ],
                          ),

                          ...List.generate(
                            provider.stops.length > 1
                                ? provider.stops.length - 1
                                : 0,
                            (i) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.more_vert, size: 20),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.pin_drop,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: PlaceSearchField(
                                        index: i + 1,
                                        hint: 'Destino ${i + 1}',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                provider.addEmptyStop();
                              },
                              icon: const Icon(Icons.add),
                              label: Text(
                                'Adicionar destino',
                                style: TextStyle(color: Color(0xFF666666)),
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
            );
          },
        ),
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
