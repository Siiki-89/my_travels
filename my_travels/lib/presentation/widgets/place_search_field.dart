import 'package:flutter/material.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/services/google_maps_service.dart';
import 'package:provider/provider.dart';

class PlaceSearchField extends StatelessWidget {
  final int index;
  final String hint;

  const PlaceSearchField({super.key, required this.index, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<LocationMapModel>(
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) return [];
        final service = GoogleMapsSerivce();
        return await service.searchLocation(textEditingValue.text);
      },
      displayStringForOption: (place) => place.description,
      fieldViewBuilder: (ctx, controller, focus, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focus,

          decoration: InputDecoration(
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.place),
            hintText: hint,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
    );
  }
}
