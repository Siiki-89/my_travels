// In lib/presentation/pages/create_travel_page.dart (or its own file)

import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/create_travel_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/services/google_maps_service.dart';

/// A widget that provides a search field for places using Google Autocomplete.
/// It also expands to show additional fields for editing destination details.
class PlaceSearchField extends StatelessWidget {
  final DestinationModel destination;
  final int index;
  final String hint;

  /// Creates an instance of [PlaceSearchField].
  const PlaceSearchField({
    super.key,
    required this.index,
    required this.hint,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateTravelProvider>();
    final l10n = AppLocalizations.of(context)!;
    final bool isStartPoint = (index == 0);

    if (isStartPoint) {
      return _buildAutocompleteField(context, provider);
    } else {
      return _buildAnimatedCard(context, provider, l10n);
    }
  }

  /// Builds an animated container that expands/collapses to show editing fields.
  Widget _buildAnimatedCard(
    BuildContext context,
    CreateTravelProvider provider,
    AppLocalizations l10n,
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
            if (isEditing) _buildAdditionalFields(context, provider, l10n),
          ],
        ),
      ),
    );
  }

  /// Builds the core text field with Google Places Autocomplete functionality.
  Widget _buildAutocompleteField(
    BuildContext context,
    CreateTravelProvider provider,
  ) {
    // This check makes the logic clearer.
    final bool isStartPoint = (index == 0);

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
            provider.updateDestinationLocation(index, detail);
            context.read<MapProvider>().setStop(index, detail);
            // This was your original logic, kept as is.
            if (index == 0) {
              provider.concludeEditing();
            }
          }
        },
        fieldViewBuilder: (ctx, controller, focus, onSubmitted) {
          // Syncs the controller's text with the model's state, e.g., after a form reset.
          final String modelText = destination.location?.description ?? '';
          if (controller.text != modelText && !focus.hasFocus) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.text = modelText;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            });
          }

          final textFormField = TextFormField(
            controller: controller,
            focusNode: focus,
            decoration: InputDecoration(
              labelText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // If it's the starting point, return the text field directly.
          if (isStartPoint) {
            return textFormField;
          }
          // Otherwise, maintain the two-tap expansion logic.
          else {
            final hasTapped = provider.hasTappedOnce(index);

            return GestureDetector(
              onTap: () {
                if (!hasTapped) {
                  // The previous fix is kept here to prevent the keyboard
                  // from opening when expanding other destinations.
                  _handleFirstTap(context, provider, index);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    FocusScope.of(context).unfocus();
                  });
                }
              },
              child: AbsorbPointer(
                absorbing: !hasTapped,
                child: textFormField, // Reuses the widget created above
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds the additional fields (description, dates, save button) that appear on expansion.
  Widget _buildAdditionalFields(
    BuildContext context,
    CreateTravelProvider provider,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          TextFormField(
            key: ValueKey('description_$index'),
            controller: provider.descriptionController,
            decoration: InputDecoration(
              labelText: l10n.travelAddDecriptionText,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDateField(
                context,
                l10n.travelAddStart,
                provider.arrivalDateString,
                () => _selectDate(context, true, provider),
              ),
              const SizedBox(width: 8),
              _buildDateField(
                context,
                l10n.travelAddFinal,
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
                l10n.travelAddPointButton,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single date field button.
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
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the date picker and updates the provider's state.
  Future<void> _selectDate(
    BuildContext context,
    bool isArrival,
    CreateTravelProvider provider,
  ) async {
    FocusScope.of(context).unfocus();
    DateTime initialPickerDate;
    DateTime firstSelectableDate;

    // Helper function to normalize the date (ignore time).
    DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    if (isArrival) {
      if (index == 0) {
        firstSelectableDate = provider.startDate;
      } else {
        final previousDestinationDeparture =
            provider.destinations[index - 1].departureDate;
        firstSelectableDate =
            previousDestinationDeparture ?? provider.startDate;
      }
      initialPickerDate = provider.tempArrivalDate ?? firstSelectableDate;
    } else {
      // The departure date cannot be earlier than the arrival date.
      firstSelectableDate = provider.tempArrivalDate ?? provider.startDate;
      initialPickerDate = provider.tempDepartureDate ?? firstSelectableDate;
    }

    // Normalizes dates before any comparison or passing them to the DatePicker.
    DateTime firstSelectableDay = normalizeDate(firstSelectableDate);
    DateTime initialPickerDay = normalizeDate(initialPickerDate);

    // Ensures the picker's initial date is not before the first selectable date.
    if (initialPickerDay.isBefore(firstSelectableDay)) {
      initialPickerDay = firstSelectableDay;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialPickerDay,
      firstDate: firstSelectableDay,
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

  /// Handles the logic for the first tap on a destination card to expand it.
  void _handleFirstTap(
    BuildContext context,
    CreateTravelProvider provider,
    int index,
  ) {
    // 1. Starts the editing and animation
    provider.registerFirstTap(index);
    provider.startEditing(index);

    // 2. Schedules the screen scroll
    // A small delay is used to give the expansion animation time to start.
    // This ensures the position calculation for the scroll is more accurate.
    Future.delayed(const Duration(milliseconds: 200), () {
      // It's good practice to check if the widget is still on screen ("mounted")
      // before using its 'context'.
      if (context.mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0, // Aligns to the top of the viewport
        );
      }
    });
  }
}
