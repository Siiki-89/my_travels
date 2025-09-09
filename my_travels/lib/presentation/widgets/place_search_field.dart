import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/create_travel_provider.dart';
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
    final provider = context.watch<CreateTravelProvider>();
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
    CreateTravelProvider provider,
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

  // Em place_search_field.dart

  Widget _buildAutocompleteField(
    BuildContext context,
    CreateTravelProvider provider,
  ) {
    // Adicionamos a verificação aqui para ficar mais claro
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
            if (index == 0) {
              provider.concludeEditing();
            }
          }
        },
        fieldViewBuilder: (ctx, controller, focus, onSubmitted) {
          // 1. Obtém o valor atual do seu modelo de dados.
          final String modelText = destination.location?.description ?? '';

          // 2. Compara com o texto atual do controller. Se forem diferentes,
          //    significa que o estado mudou (como no reset) e a UI precisa ser atualizada.
          if (controller.text != modelText) {
            // Adia a atualização do controller para o final do frame de build.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.text = modelText;
            });
          }

          // 1. Criamos o TextFormField uma única vez para evitar repetição
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

          // 2. Lógica condicional:
          // Se for o ponto de partida, retorna o campo de texto diretamente.
          if (isStartPoint) {
            return textFormField;
          }
          // Caso contrário, mantém a lógica de expansão com dois cliques.
          else {
            final hasTapped = provider.hasTappedOnce(index);

            return GestureDetector(
              onTap: () {
                if (!hasTapped) {
                  provider.registerFirstTap(index);
                  provider.startEditing(index);
                  // A correção anterior é mantida aqui para evitar que o
                  // teclado abra ao expandir os outros destinos.
                  _handleFirstTap(context, provider, index);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    FocusScope.of(context).unfocus();
                  });
                }
              },
              child: AbsorbPointer(
                absorbing: !hasTapped,
                child: textFormField, // Reutilizamos o widget criado acima
              ),
            );
          }
          // --- FIM DA MODIFICAÇÃO ---
        },
      ),
    );
  }

  Widget _buildAdditionalFields(
    BuildContext context,
    CreateTravelProvider provider,
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
                provider.resetAllTaps();
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
                style: TextStyle(color: Colors.blue, fontSize: 14),
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
    CreateTravelProvider provider,
  ) async {
    DateTime initialPickerDate;
    DateTime firstSelectableDate;

    // Função auxiliar para normalizar a data (ignorar horas/minutos)
    DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

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
      // A data de partida não pode ser anterior à data de chegada.
      firstSelectableDate = provider.tempArrivalDate ?? provider.startData;
      initialPickerDate = provider.tempDepartureDate ?? firstSelectableDate;
    }

    // ### CORREÇÃO APLICADA AQUI ###
    // Normaliza as datas antes de qualquer comparação ou de passá-las ao DatePicker.
    DateTime firstSelectableDay = normalizeDate(firstSelectableDate);
    DateTime initialPickerDay = normalizeDate(initialPickerDate);

    // Garante que a data inicial do picker não seja anterior à primeira data selecionável.
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

  void _handleFirstTap(
    BuildContext context,
    CreateTravelProvider provider,
    int index,
  ) {
    // 1. Inicia a edição e animação
    provider.registerFirstTap(index);
    provider.startEditing(index);

    // 2. Agenda a rolagem da tela
    // Usamos um pequeno delay para dar tempo da animação de expansão começar.
    // Isso garante que o cálculo da posição para o scroll seja mais preciso.
    Future.delayed(const Duration(milliseconds: 200), () {
      // É uma boa prática verificar se o widget ainda está na tela ("montado")
      // antes de usar seu 'context'.
      if (context.mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(
            milliseconds: 400,
          ), // Duração da animação de rolagem
          curve: Curves.easeInOut,
          alignment:
              0, // Alinhamento na tela (0.0 = topo, 0.5 = meio, 1.0 = fim)
        );
      }
    });
  }
}
