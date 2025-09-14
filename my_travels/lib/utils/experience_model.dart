import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';

import 'package:my_travels/model/experience_model.dart';

/// Returns the list of all available experience models.
///
/// This function centralizes the logic so it can be used on multiple screens,
/// fetching the translated labels from the provided [context].
List<ExperienceModel> getAvailableExperiences(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  // Using a constant for the base path makes the code cleaner and easier to maintain.
  const String imagePath = 'assets/images/experience/';

  return [
    ExperienceModel(label: l10n.experiencePark, image: '${imagePath}park.png'),
    ExperienceModel(label: l10n.experienceBar, image: '${imagePath}bar.png'),
    ExperienceModel(
      label: l10n.experienceCulinary,
      image: '${imagePath}culinary.png',
    ),
    ExperienceModel(
      label: l10n.experienceHistoric,
      image: '${imagePath}historic.png',
    ),
    ExperienceModel(
      label: l10n.experienceNature,
      image: '${imagePath}nature.png',
    ),
    ExperienceModel(
      label: l10n.experienceCulture,
      image: '${imagePath}culture.png',
    ),
    ExperienceModel(label: l10n.experienceShow, image: '${imagePath}show.png'),
  ];
}
