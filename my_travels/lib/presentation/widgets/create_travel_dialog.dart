import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/experience_model.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:provider/provider.dart';

class CreateTravelDialog extends StatelessWidget {
  const CreateTravelDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Dialog(
      shadowColor: Colors.black87,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: size.width * 0.95,
        height: size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                appLocalizations.experienceTitle,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<TravelProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: provider.availableExperiences.map((
                          experience,
                        ) {
                          final bool isSelected = provider.isSelected(
                            experience,
                          );
                          return GestureDetector(
                            onTap: () => provider.toggleExperience(experience),
                            child: Container(
                              width: (size.width / 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white10,
                                            width: isSelected ? 3 : 1.0,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(experience.image),
                                            fit: BoxFit.cover,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
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
                                            padding: const EdgeInsets.all(2),
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      experience.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
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
              const SizedBox(height: 12),
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
    );
  }
}
