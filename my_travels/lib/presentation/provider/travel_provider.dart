import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/experience_model.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/model/transport_model.dart';

class TravelProvider with ChangeNotifier {
  //Data
  DateTime _startData = DateTime.now();
  DateTime _finalData = DateTime.now();

  DateTime get startData => _startData;
  DateTime get finalData => _finalData;

  String get startDateString => formatDate(_startData);
  String get finalDateString => formatDate(_finalData);

  File? _coverImage;

  File? get coverImage => _coverImage;

  void setImage(File? newImage) {
    _coverImage = newImage;
    notifyListeners();
  }


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
      ExperienceModel(
        label: appLocalizations.experiencePark,
        image: 'assets/images/experience/park.png',
      ),
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

  bool isSelectedExperience(ExperienceModel experience) {
    return _selectedExperiences.contains(experience);
  }

  void toggleExperience(ExperienceModel experience) {
    if (isSelectedExperience(experience)) {
      _selectedExperiences.remove(experience);
    } else {
      _selectedExperiences.add(experience);
    }
    notifyListeners();
  }

  //Tipo de veiculo
  TransportModel _transportSelect = TransportModel(label: '', image: '');
  TransportModel get transportSelect => _transportSelect;

  final List<TransportModel> _availableTransport = [];

  List<TransportModel> get availableTransport => _availableTransport;

  bool isSelectedVehicle(TransportModel transport) =>
      _transportSelect.label == transport.label;

  void selectVehicle(TransportModel transport) {
    _transportSelect = transport;
    notifyListeners();
  }

  void loadAvailableVehicles(BuildContext context) {
    if (_availableTransport.isNotEmpty) return;
    final appLocalizations = AppLocalizations.of(context)!;

    _availableTransport.clear();

    _availableTransport.addAll([
      TransportModel(
        label: appLocalizations.vehicleCar,
        image: 'assets/images/typelocomotion/car.png',
      ),
      TransportModel(
        label: appLocalizations.vehicleMotorcycle,
        image: 'assets/images/typelocomotion/motorcycle.png',
      ),
      TransportModel(
        label: appLocalizations.vehicleBus,
        image: 'assets/images/typelocomotion/bus.png',
      ),
      TransportModel(
        label: appLocalizations.vehicleAirplane,
        image: 'assets/images/typelocomotion/airplane.png',
      ),
      TransportModel(
        label: appLocalizations.vehicleCruise,
        image: 'assets/images/typelocomotion/cruise.png',
      ),
    ]);
  }

  final List<DestinationModel> _destinations = [DestinationModel(id: 0)];
  List<DestinationModel> get destinations => _destinations;

  int _nextId = 1;

  int? _editingIndex;
  int? get editingIndex => _editingIndex;

  final TextEditingController descriptionController = TextEditingController();
  DateTime? _tempArrivalDate;
  DateTime? _tempDepartureDate;

  String get arrivalDateString => _tempArrivalDate != null
      ? DateFormat('dd/MM/yyyy').format(_tempArrivalDate!)
      : 'Selecione';
  String get departureDateString => _tempDepartureDate != null
      ? DateFormat('dd/MM/yyyy').format(_tempDepartureDate!)
      : 'Selecione';

  void startEditing(int index) {
    _editingIndex = index;
    final destination = _destinations[index];

    descriptionController.text = destination.description ?? '';
    _tempArrivalDate = destination.arrivalDate ?? DateTime.now();
    _tempDepartureDate =
        destination.departureDate ??
        DateTime.now().add(const Duration(days: 1));

    notifyListeners();
  }

  void concludeEditing() {
    if (_editingIndex != null) {
      final destination = _destinations[_editingIndex!];
      _destinations[_editingIndex!] = destination.copyWith(
        description: descriptionController.text,
        arrivalDate: _tempArrivalDate,
        departureDate: _tempDepartureDate,
      );

      _editingIndex = null;
      descriptionController.clear();
      _tempArrivalDate = null;
      _tempDepartureDate = null;

      notifyListeners();
    }
  }

  void addDestination() {
    final newDestination = DestinationModel(id: _nextId++);
    _destinations.add(newDestination);
    startEditing(_destinations.length - 1);
  }

  void updateDestinationLocation(LocationMapModel location) {
    if (_editingIndex != null) {
      final destination = _destinations[_editingIndex!];
      _destinations[_editingIndex!] = destination.copyWith(location: location);
      notifyListeners();
    }
  }

  void updateArrivalDate(DateTime date) {
    _tempArrivalDate = date;
    notifyListeners();
  }

  void updateDepartureDate(DateTime date) {
    _tempDepartureDate = date;
    notifyListeners();
  }

  void removeDestinationById(int id) {
    _destinations.removeWhere((dest) => dest.id == id);

    if (_editingIndex != null && _editingIndex! < _destinations.length) {
      if (_destinations[_editingIndex!].id == id) {
        _editingIndex = null;
        descriptionController.clear();
        _tempArrivalDate = null;
        _tempDepartureDate = null;
      }
    }

    notifyListeners();
  }
}
