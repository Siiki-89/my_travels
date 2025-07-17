import 'package:flutter/material.dart';

class SelectTransport extends StatelessWidget {
  const SelectTransport({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> vehicles = [
      {'icon': Icons.directions_car, 'label': 'Carro'},
      {'icon': Icons.motorcycle, 'label': 'Moto'},
      {'icon': Icons.directions_bus, 'label': 'Ônibus'},
      {'icon': Icons.local_taxi, 'label': 'Táxi'},
      {'icon': Icons.train, 'label': 'Trem'},
      {'icon': Icons.airport_shuttle, 'label': 'Van'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vehicles.map((vehicle) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(vehicle['icon'], size: 30, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(vehicle['label'], style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
