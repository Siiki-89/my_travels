import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';

import 'package:my_travels/model/destination_model.dart';

/// A widget that displays a vertical list of travel destinations,
/// visually representing a route.
class TravelRouteDisplay extends StatelessWidget {
  /// The list of destinations to display.
  final List<DestinationModel> destinations;

  /// Creates an instance of [TravelRouteDisplay].
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

        // The builder now simply creates the tile widget.
        return _DestinationTile(
          destination: destination,
          isLastItem: isLastItem,
        );
      },
      separatorBuilder: (context, index) {
        // Builds the vertical dotted line effect between tiles.
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
}

/// A private widget that builds a single row for a destination in the route.
class _DestinationTile extends StatelessWidget {
  final DestinationModel destination;
  final bool isLastItem;

  /// Creates an instance of [_DestinationTile].
  const _DestinationTile({required this.destination, required this.isLastItem});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              destination.location?.description ?? l10n.destinationNotDefined,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
