import 'package:flutter/cupertino.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/experience_model.dart';
import 'package:intl/intl.dart';

class TravelProvider with ChangeNotifier {
  //Data
  DateTime _startData = DateTime.now();
  DateTime _finalData = DateTime.now();

  DateTime get startData => _startData;
  DateTime get finalData => _finalData;

  String get startDateString => formatDate(_startData);
  String get finalDateString => formatDate(_finalData);

  void updateDate(DateTime newDate, bool isStartDate) {
    if (isStartDate) {
      _startData = newDate;
      if (_finalData.isBefore(_startData)) {
        _finalData = _startData;
      }
    } else {
      _finalData = newDate;
    }
    notifyListeners();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  //Experiencias
  final List<ExperienceModel> _selectedExperiences = [];
  List<ExperienceModel> get selectedExperiences => _selectedExperiences;

  final List<ExperienceModel> _availableExperiences = [];

  List<ExperienceModel> get availableExperiences => _availableExperiences;

  void loadAvailableExperiences(BuildContext context) {
    if (_availableExperiences.isNotEmpty) return;
    final appLocalizations = AppLocalizations.of(context)!;

    _availableExperiences.clear();

    _availableExperiences.addAll([
      ExperienceModel(label: "bar", image: 'assets/images/experience/park.png'),
      ExperienceModel(
        label: appLocalizations.experienceBar,
        image: 'assets/images/experience/bar.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceCulinary,
        image: 'assets/images/experience/culinary.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceHistoric,
        image: 'assets/images/experience/historic.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceNature,
        image: 'assets/images/experience/nature.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceCulture,
        image: 'assets/images/experience/culture.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceShow,
        image: 'assets/images/experience/show.png',
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

  //Tipo de veiculo
  final String _transportSelect = '';
  String get transportSelect => _transportSelect;

  final List<ExperienceModel> _availableTransport = [];

  List<ExperienceModel> get availableTransport => _availableTransport;
}
