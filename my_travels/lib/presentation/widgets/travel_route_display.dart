import 'package:flutter/material.dart';
import 'package:my_travels/model/destination_model.dart'; // Importe seu modelo

class TravelRouteDisplay extends StatelessWidget {
  final List<DestinationModel> destinations;

  const TravelRouteDisplay({super.key, required this.destinations});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        final bool isLastItem = index == destinations.length - 1;

        return _buildDestinationTile(destination, isLastItem);
      },
      separatorBuilder: (context, index) {
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

  Widget _buildDestinationTile(DestinationModel destination, bool isLastItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isLastItem ? Icons.location_pin : Icons.circle_outlined,
          color: isLastItem ? Colors.red : Colors.grey.shade600,
          size: 24,
        ),
        const SizedBox(width: 16),

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
