import 'package:flutter/material.dart';
import 'package:my_travels/model/destination_model.dart'; // Importe seu modelo

class TravelRouteDisplay extends StatelessWidget {
  final List<DestinationModel> destinations;

  const TravelRouteDisplay({
    super.key,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos ListView.separated para construir a lista com os "pontinhos" entre os itens.
    return ListView.separated(
      shrinkWrap: true, // Para usar dentro de uma Column
      physics: const NeverScrollableScrollPhysics(), // Para não ter scroll próprio
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        final bool isLastItem = index == destinations.length - 1;

        // Cada item da lista é uma linha (Row) com o ícone e o card.
        return _buildDestinationTile(destination, isLastItem);
      },
      separatorBuilder: (context, index) {
        // O separador são os três pontinhos verticais.
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
            child: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
          ),
        );
      },
    );
  }

  // Widget auxiliar para construir cada linha da rota
  Widget _buildDestinationTile(DestinationModel destination, bool isLastItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. O ÍCONE (Círculo cinza ou Pino vermelho)
        Icon(
          isLastItem ? Icons.location_pin : Icons.circle_outlined,
          color: isLastItem ? Colors.red : Colors.grey.shade600,
          size: 24,
        ),
        const SizedBox(width: 16),

        // 2. O CARD COM O NOME DO LOCAL
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              destination.location?.description ?? 'Destino não definido',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}