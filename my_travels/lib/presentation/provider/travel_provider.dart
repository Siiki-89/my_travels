import 'package:flutter/cupertino.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/experience_model.dart';

class TravelProvider with ChangeNotifier {
  final List<ExperienceModel> _selectedExperiences = [];
  List<ExperienceModel> get selectedExperiences => _selectedExperiences;

  final List<ExperienceModel> _availableExperiences = [];

  List<ExperienceModel> get availableExperiences => _availableExperiences;

  void loadAvailableExperiences(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    _availableExperiences.clear();

    _availableExperiences.addAll([
      ExperienceModel(
        label: appLocalizations.experiencePark,
        image: 'assets/images/park.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceBar,
        image: 'assets/images/bar.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceCulinary,
        image: 'assets/images/culinary.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceHistoric,
        image: 'assets/images/historic.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceNature,
        image: 'assets/images/nature.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceCulture,
        image: 'assets/images/culture.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceShow,
        image: 'assets/images/show.png',
      ),
    ]);
  }

  bool isSelected(ExperienceModel experience) {
    return _selectedExperiences.contains(experience);
  }

  void toggleExperience(ExperienceModel experience) {
    if (isSelected(experience)) {
      _selectedExperiences.remove(experience);
    } else {
      _selectedExperiences.add(experience);
    }
    notifyListeners();
  }
}
