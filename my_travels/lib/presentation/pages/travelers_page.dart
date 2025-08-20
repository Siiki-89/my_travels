import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/widgets/build_empty_state.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:my_travels/presentation/widgets/traveler_create_dialog.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class TravelersPage extends StatelessWidget {
  const TravelersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.users), centerTitle: true),
      body: SafeArea(
        child: travelerProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : travelerProvider.travelers.isEmpty
            ? buildEmptyState(
                context,
                'assets/images/lottie/general/man_with_map.json',
                appLocalizations.noTravelersTitle,
                appLocalizations.noTravelersSubtitle,
                appLocalizations.travelerManagementHint,
              )
            : _buildTravelerList(travelerProvider, appLocalizations, context),
      ),
      floatingActionButton: _buildLottieButton(travelerProvider, context),
    );
  }

  Widget _buildTravelerList(
    TravelerProvider travelerProvider,
    AppLocalizations appLocalizations,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: travelerProvider.travelers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final traveler = travelerProvider.travelers[index];
              return ListTile(
                onTap: () {
                  context.read<TravelerProvider>().prepareForEdit(traveler);
                  showSmoothDialog(context, const CreateAddTravelerDialog());
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      traveler.photoPath != null &&
                          traveler.photoPath!.isNotEmpty
                      ? FileImage(File(traveler.photoPath!))
                      : null,
                  child:
                      traveler.photoPath == null || traveler.photoPath!.isEmpty
                      ? const Icon(Icons.person, size: 34)
                      : null,
                ),
                title: Text(
                  traveler.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${appLocalizations.ageHint}: ${traveler.age}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text(
                                appLocalizations.confirmDeletion,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                '${appLocalizations.areYouSureYouWantToDelete} ${traveler.name}?',
                              ),
                              actions: [
                                TextButton(
                                  child: Text(appLocalizations.cancel),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: Text(appLocalizations.delete),
                                  onPressed: () async {
                                    await context
                                        .read<TravelerProvider>()
                                        .deleteTraveler(traveler.id, context);

                                    if (!dialogContext.mounted) return;
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  InkWell _buildLottieButton(TravelerProvider provider, BuildContext context) {
    return InkWell(
      onTap: () async {
        if (provider.onPressed) return;

        provider.changeOnPressed();
        await Future.delayed(const Duration(milliseconds: 1200));

        showSmoothDialog(context, const CreateAddTravelerDialog());

        await Future.delayed(const Duration(milliseconds: 200));
        provider.changeOnPressed();
      },
      splashColor: Colors.transparent,
      child: Lottie.asset(
        'assets/images/lottie/buttons/add_button.json',
        key: ValueKey(provider.onPressed),
        animate: provider.onPressed,
        width: 70,
        height: 70,
      ),
    );
  }
}
