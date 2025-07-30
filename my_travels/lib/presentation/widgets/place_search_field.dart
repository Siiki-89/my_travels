import 'package:flutter/material.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:my_travels/services/google_maps_service.dart';
import 'package:provider/provider.dart';

class PlaceSearchField extends StatelessWidget {
  DestinationModel? destination;
  final int index;
  final String hint;

  PlaceSearchField({
    super.key,
    required this.index,
    required this.hint,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Autocomplete<LocationMapModel>(
              optionsBuilder: (textEditingValue) async {
                if (textEditingValue.text.isEmpty) return [];
                final service = GoogleMapsService();
                return await service.searchLocation(textEditingValue.text);
              },
              displayStringForOption: (place) => place.description,
              onSelected: (prediction) async {
                final service = GoogleMapsService();
                final detail = await service.placeDetail(
                  prediction.locationId,
                  prediction.description,
                );
                if (detail != null && context.mounted) {
                  context.read<MapProvider>().setStop(index, detail);
                }
              },
              fieldViewBuilder: (ctx, controller, focus, onSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focus,
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    labelText: hint,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            if (index >= 1)
              Column(
                children: [
                  TextFormField(
                    controller: provider.descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (o que fará aqui?)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateSelector(
                          context: context,
                          label: 'Chegada',
                          date: provider.arrivalDate ?? DateTime.now(),
                          onTap: () => _selectDate(context, true, provider),
                          provider: provider,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDateSelector(
                          context: context,
                          label: 'Saída',
                          date: provider.departureDate ?? DateTime.now(),
                          onTap: () => _selectDate(context, false, provider),
                          provider: provider,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isArrival,
    TravelProvider provider,
  ) async {
    final initialDate =
        (isArrival ? provider.arrivalDate : provider.departureDate) ??
        DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isArrival) {
        provider.updateArrivalDate(destination?.id, pickedDate);
      } else {
        provider.updateDepartureDate(destination?.id, pickedDate);
      }
    }
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required TravelProvider provider,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(provider.formatDate(date)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
