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
    final provider = context.watch<TravelProvider>();
    final loc = AppLocalizations.of(context)!;
    final bool isStartPoint = (index == 0);

    if (isStartPoint) {
      return _buildAutocompleteField(context, provider);
    } else {
      return _buildAnimatedCard(context, provider, loc);
    }
  }

  Widget _buildAnimatedCard(
    BuildContext context,
    TravelProvider provider,
    AppLocalizations loc,
  ) {
    final bool isEditing = provider.editingIndex == index;
    final double containerHeight = isEditing ? 310.0 : 60.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: containerHeight,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildAutocompleteField(context, provider),

            if (isEditing) _buildAdditionalFields(context, provider, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompleteField(
    BuildContext context,
    TravelProvider provider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Autocomplete<LocationMapModel>(
        initialValue: TextEditingValue(
          text: destination.location?.description ?? '',
        ),
        optionsBuilder: (textEditingValue) async {
          if (textEditingValue.text.length < 2) return [];
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
            FocusScope.of(context).unfocus();
            provider.updateDestinationLocation(detail);
            context.read<MapProvider>().setStop(index, detail);
            if (index == 0) {
              provider.concludeEditing();
            }
          }
        },
        fieldViewBuilder: (ctx, controller, focus, onSubmitted) {
          final hasTapped = provider.hasTappedOnce(index);

          return GestureDetector(
            onTap: () {
              if (!hasTapped) {
                provider.registerFirstTap(index);
                provider.startEditing(index);
                FocusScope.of(context).unfocus();
              }
            },
            child: AbsorbPointer(
              absorbing: !hasTapped,
              child: TextFormField(
                controller: controller,
                focusNode: focus,
                decoration: InputDecoration(
                  labelText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdditionalFields(
    BuildContext context,
    TravelProvider provider,
    AppLocalizations loc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          TextFormField(
            key: ValueKey('description_$index'),
            controller: provider.descriptionController,
            decoration: InputDecoration(
              labelText: loc.travelAddDecriptionText,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDateField(
                context,
                loc.travelAddStart,
                provider.arrivalDateString,
                () => _selectDate(context, true, provider),
              ),
              const SizedBox(width: 8),
              _buildDateField(
                context,
                loc.travelAddFinal,
                provider.departureDateString,
                () => _selectDate(context, false, provider),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                provider.resetFirstTap(index);
                provider.concludeEditing();
              },
              style: AppButtonStyles.saveButtonStyle,
              child: Text(
                loc.travelAddPointButton,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    String value,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                value,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isArrival,
    TravelProvider provider,
  ) async {
    DateTime initialPickerDate;
    DateTime firstSelectableDate;

    if (isArrival) {
      if (index == 0) {
        firstSelectableDate = provider.startData;
      } else {
        final previousDestinationDeparture =
            provider.destinations[index - 1].departureDate;
        firstSelectableDate =
            previousDestinationDeparture ?? provider.startData;
      }
      initialPickerDate = provider.tempArrivalDate ?? firstSelectableDate;
    } else {
      firstSelectableDate = provider.tempArrivalDate ?? provider.startData;
      initialPickerDate = provider.tempDepartureDate ?? firstSelectableDate;
    }

    if (initialPickerDate.isBefore(firstSelectableDate)) {
      initialPickerDate = firstSelectableDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialPickerDate,
      firstDate: firstSelectableDate,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      if (isArrival) {
        provider.updateArrivalDate(picked);
      } else {
        provider.updateDepartureDate(picked);
      }
    }
  }
}
