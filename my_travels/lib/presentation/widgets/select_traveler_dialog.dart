import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:provider/provider.dart';

class CreateTravelerDialog extends StatelessWidget {
  const CreateTravelerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Dialog(
      shadowColor: Colors.black87,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.95,
          maxHeight: size.height * 0.75,
        ),
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    appLocalizations.travelerToTravelTitle,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer<TravelerProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (provider.errorMessage != null) {
                          return Center(child: Text(provider.errorMessage!));
                        }
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: provider.travelers.map((traveler) {
                              final bool isSelected = provider.isSelected(
                                traveler,
                              );
                              return GestureDetector(
                                onTap: () => provider.toggleTraveler(traveler),
                                child: Container(
                                  width: (size.width / 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.transparent,
                                                width: isSelected ? 3 : 1.0,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage:
                                                  traveler.photoPath != null
                                                  ? FileImage(
                                                      File(traveler.photoPath!),
                                                    )
                                                  : null,
                                              child: traveler.photoPath == null
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: Colors.black,
                                                    )
                                                  : null,
                                            ),
                                          ),

                                          if (isSelected)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        traveler.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButtonStyle,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        appLocalizations.saveButton,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
