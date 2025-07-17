import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/create_experience_dialog.dart';
import 'package:my_travels/presentation/widgets/create_traveler_dialog.dart';
import 'package:provider/provider.dart';

class CreateTravelPage extends StatelessWidget {
  const CreateTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.add), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.travelAddTitle),
                    TextFormField(
                      decoration: InputDecoration(hintText: loc.travelAddTitle),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.travelAddStart),
                              TextFormField(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.travelAddFinal),
                              TextFormField(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(loc.travelAddTypeLocomotion),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text(''),
                        items: [],
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(loc.users),
                        IconButton(
                          onPressed: () {
                            context.read<TravelerProvider>().loadTravelers(
                              context,
                            );

                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return const CreateTravelerDialog();
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Color(0xFF176FF2),
                          ),
                        ),
                      ],
                    ),
                    Consumer<TravelerProvider>(
                      builder: (context, provider, child) {
                        if (provider.selectedTravelers.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            children: provider.selectedTravelers.map((
                              travelers,
                            ) {
                              return Chip(
                                label: Text(travelers.name),
                                onDeleted: () {
                                  provider.toggleTraveler(travelers);
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: loc.travelerNameHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.pin_drop, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(loc.travelAddStartintPoint),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(loc.travelAddTypeInterest),
                        IconButton(
                          onPressed: () {
                            context
                                .read<TravelProvider>()
                                .loadAvailableExperiences(context);

                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return const CreateTravelDialog();
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Color(0xFF176FF2),
                          ),
                        ),
                      ],
                    ),
                    Consumer<TravelProvider>(
                      builder: (context, provider, child) {
                        if (provider.selectedExperiences.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            children: provider.selectedExperiences.map((
                              experience,
                            ) {
                              return Chip(
                                label: Text(experience.label),
                                onDeleted: () {
                                  provider.toggleExperience(experience);
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: AppButtonStyles.primaryButtonStyle,
                        child: Text(
                          loc.saveButton,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
