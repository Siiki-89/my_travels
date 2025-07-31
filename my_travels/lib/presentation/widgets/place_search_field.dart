import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
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

    // Mostra o formulário de edição se o índice corresponder ao índice de edição
    if (provider.editingIndex == index) {
      return _buildEditingView(context, provider, loc);
    } else {
      // Caso contrário, mostra a visualização de exibição (clicável para editar)
      return _buildDisplayView(context, provider);
    }
  }

  // Visualização para quando o destino NÃO está sendo editado
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

  // Visualização para quando o destino ESTÁ sendo editado
  Widget _buildEditingView(
    BuildContext context,
    TravelProvider provider,
    AppLocalizations loc,
  ) {
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
              // Atualiza o destino no provider
              provider.updateDestinationLocation(detail);
              // Atualiza o marcador no mapa
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
        const SizedBox(height: 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              TextFormField(
                controller: provider.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (o que fará aqui?)',
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
                          child: Text(provider.arrivalDateString),
                          style: ElevatedButton.styleFrom(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
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
                          child: Text(provider.departureDateString),
                          style: ElevatedButton.styleFrom(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
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
                  ElevatedButton(
                    onPressed: () => provider.concludeEditing(),
                    child: const Text('Concluir'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      provider.removeDestinationById(destination.id);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Excluir destino',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isArrival,
    TravelProvider provider,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (isArrival) {
        provider.updateArrivalDate(pickedDate);
      } else {
        provider.updateDepartureDate(pickedDate);
      }
    }
  }
}
