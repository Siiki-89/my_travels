import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/widgets/traveler_create_dialog.dart';
import 'package:my_travels/presentation/widgets/traveler_form_input.dart';
import 'package:my_travels/presentation/widgets/traveler_list_item.dart';
import 'package:provider/provider.dart';

class TravelersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.users),
        centerTitle: true,
        actions: [
          _buildAppBarAction(
            context,
            option: 'delete',
            activeIcon: Icons.cancel,
            inactiveIcon: Icons.delete,
          ),
          _buildAppBarAction(
            context,
            option: 'edit',
            activeIcon: Icons.cancel,
            inactiveIcon: Icons.mode_edit_outline_outlined,
          ),
          _buildAppBarAction(
            context,
            option: 'add',
            activeIcon: Icons.cancel,
            inactiveIcon: Icons.add_circle_outline,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return CreateAddTrevelerDialog();
                  },
                );
              },
              child: Text(appLocalizations.addTraveler),
            ),
            if (travelerProvider.optionNow == 'add' ||
                travelerProvider.editingId != null)
              const TravelerFormInput(),

            if (travelerProvider.errorMessage != null &&
                travelerProvider.errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  travelerProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: travelerProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : travelerProvider.travelers.isEmpty
                  ? Center(child: Text(appLocalizations.noTravelersRegistered))
                  : ListView.builder(
                      itemCount: travelerProvider.travelers.length,
                      itemBuilder: (context, index) {
                        final traveler = travelerProvider.travelers[index];
                        return TravelerListItem(traveler: traveler);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (travelerProvider.optionNow == 'add' ||
              travelerProvider.editingId != null)
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF176FF2),
              child: Icon(
                travelerProvider.editingId != null ? Icons.save : Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                final name = TravelerFormInput.nameController.text;
                final age = TravelerFormInput.ageController.text;

                travelerProvider.setName(name);
                travelerProvider.setAge(age);

                if (travelerProvider.editingId != null) {
                  final updatedTraveler = Traveler(
                    id: travelerProvider.editingId,
                    name: travelerProvider.name,
                    age: travelerProvider.age,
                    photoPath: travelerProvider.selectedImage?.path,
                  );
                  await travelerProvider.editTraveler(updatedTraveler);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appLocalizations.travelerUpdatedSuccess),
                    ),
                  );
                } else {
                  await travelerProvider.addTraveler();
                  if (travelerProvider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(travelerProvider.errorMessage!)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLocalizations.travelerAddedSuccess),
                      ),
                    );
                  }
                }
              },
            )
          : null,
    );
  }

  Widget _buildAppBarAction(
    BuildContext context, {
    required String option,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final travelerProvider = context.read<TravelerProvider>();
    final bool isActive = travelerProvider.optionNow == option;

    return IconButton(
      onPressed: () {
        travelerProvider.changeOptionNow(option);
        travelerProvider.setEditingId(null);
      },
      icon: Icon(isActive ? activeIcon : inactiveIcon),
    );
  }
}
