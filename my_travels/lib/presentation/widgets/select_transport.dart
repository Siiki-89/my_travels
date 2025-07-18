import 'package:flutter/material.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:provider/provider.dart';

class SelectTransport extends StatelessWidget {
  const SelectTransport({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelProvider>(
      builder: (context, provider, _) {
        provider.loadAvailableVehicles(context);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: provider.availableTransport.map((vehicle) {
              final bool isSelected = provider.isSelectedVehicle(vehicle);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () => provider.selectVehicle(vehicle),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            width: 60,
                            height: 60,
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white10,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                vehicle.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
