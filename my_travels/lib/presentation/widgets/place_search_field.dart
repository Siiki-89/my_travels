import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/services/google_maps_service.dart';
import 'package:provider/provider.dart';

class PlaceSearchField extends StatelessWidget {
  final DestinationModel destination;
  final int index;
  final String hint;

  const PlaceSearchField({
    super.key,
    required this.index,
    required this.hint,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final provider = context.watch<TravelProvider>();

    if (provider.editingIndex == index) {
      return _buildEditingView(context, provider, loc);
    } else {
      return _buildDisplayView(context, provider);
    }
  }

  Widget _buildDisplayView(BuildContext context, TravelProvider provider) {
    return InkWell(
      onTap: () => provider.startEditing(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          destination.location?.description ?? hint,
          style: TextStyle(
            color: destination.location == null
                ? Colors.grey.shade600
                : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEditingView(
    BuildContext context,
    TravelProvider provider,
    AppLocalizations loc,
  ) {
    final bool isStartPoint = (index == 0);

    if (isStartPoint) {
      return Autocomplete<LocationMapModel>(
        initialValue: TextEditingValue(
          text: destination.location?.description ?? '',
        ),
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
            provider.updateDestinationLocation(detail);
            context.read<MapProvider>().setStop(index, detail);
            provider.concludeEditing();
          }
        },
        fieldViewBuilder: (ctx, controller, focus, onSubmitted) {
          FocusScope.of(ctx).requestFocus(focus);
          return TextFormField(
            controller: controller,
            focusNode: focus,
            decoration: InputDecoration(
              labelText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      );
    } else {
      return Column(
        children: [
          Autocomplete<LocationMapModel>(
            initialValue: TextEditingValue(
              text: destination.location?.description ?? '',
            ),
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
              if (detail != null) {
                provider.updateDestinationLocation(detail);
                context.read<MapProvider>().setStop(index, detail);
              }
            },
            fieldViewBuilder: (ctx, controller, focus, onSubmitted) {
              FocusScope.of(ctx).requestFocus(focus);
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

          const SizedBox(height: 16),
          Column(
            children: [
              TextFormField(
                controller: provider.descriptionController,
                decoration: InputDecoration(
                  labelText: loc.travelAddDecriptionText,
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
                          onPressed: () => _selectDate(context, true, provider),
                          style: ElevatedButton.styleFrom(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            provider.arrivalDateString,
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
                          onPressed: () =>
                              _selectDate(context, false, provider),
                          style: ElevatedButton.styleFrom(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            provider.departureDateString,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => provider.concludeEditing(),
                      child: Text(
                        loc.saveButton,
                        style: TextStyle(color: Colors.white),
                      ),
                      style: AppButtonStyles.saveButtonStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isArrival,
    TravelProvider provider,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {}
  }
}
