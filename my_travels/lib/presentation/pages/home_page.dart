import 'package:flutter/material.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/services/geolocator_service.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchTravels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Viagens')),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.travels.isEmpty) {
            return const Center(child: Text('Nenhuma viagem salva ainda.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.travels.length,
            itemBuilder: (context, index) {
              final travel = provider.travels[index];
              return TravelCard(travel: travel);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/addTravel');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TravelCard extends StatelessWidget {
  final Travel travel;
  const TravelCard({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = DateFormat('dd/MM/yy').format(travel.startDate);
    final formattedEndDate = DateFormat('dd/MM/yy').format(travel.endDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (travel.coverImagePath != null &&
              travel.coverImagePath!.isNotEmpty)
            Image.file(
              File(travel.coverImagePath!),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 150,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travel.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$formattedStartDate - $formattedEndDate',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (travel.travelers.isNotEmpty)
                  Text('com ${travel.travelers.map((t) => t.name).join(', ')}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
