import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:provider/provider.dart';

class TravelerListItem extends StatelessWidget {
  final Traveler traveler;

  const TravelerListItem({super.key, required this.traveler});

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();

    return ListTile(
      leading: traveler.photoPath != null && traveler.photoPath!.isNotEmpty
          ? CircleAvatar(
              backgroundImage: FileImage(File(traveler.photoPath!)),
              radius: 28,
            )
          : const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF666666),
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
      title: Text(traveler.name),
      subtitle: Text('Idade: ${traveler.age ?? '?'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (travelerProvider.optionNow == 'edit')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.read<TravelerProvider>().prepareForEdit(traveler);
                context.read<TravelerProvider>().setOptionNow('add');
                context.read<TravelerProvider>().setEditingId(traveler.id);
              },
            ),
          if (travelerProvider.optionNow == 'delete')
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await context.read<TravelerProvider>().deleteTraveler(
                  traveler.id,
                );
                if (travelerProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(travelerProvider.errorMessage!)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viajante foi apagado!')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
