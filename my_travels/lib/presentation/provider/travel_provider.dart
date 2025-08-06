import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/experience_model.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/model/transport_model.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';

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

  DateTime? get tempArrivalDate => _tempArrivalDate;

  DateTime? get tempDepartureDate => _tempDepartureDate;

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

    if (destination.arrivalDate != null) {
      _tempArrivalDate = destination.arrivalDate;
      _tempDepartureDate = destination.departureDate;
    } else {
      if (index > 0) {
        final previousDepartureDate = _destinations[index - 1].departureDate;
        _tempArrivalDate = previousDepartureDate;
        _tempDepartureDate = previousDepartureDate?.add(
          const Duration(days: 1),
        );
      } else {
        _tempArrivalDate = _startData;
        _tempDepartureDate = _startData.add(const Duration(days: 1));
      }
    }

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
      _destinations[_editingIndex!] = destination.copyWith(
        location: location,
        description: location.description,
      );
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

  bool validateImage = false;
  bool validateVehicle = false;
  bool validadeTravelers = false;
  bool validadeRoute = false;

  Future<void> saveTravel(
    BuildContext context,
    TravelerProvider travelerProvider,
  ) async {
    final loc = AppLocalizations.of(context)!;

    concludeEditing();

    if (_coverImage == null) {
      _showErrorSnackBar(context, 'Por favor, selecione uma imagem de capa.');
      validateImage = true;
      notifyListeners();
      return;
    }

    validateImage = false;
    notifyListeners();

    if (_transportSelect.label.isEmpty) {
      _showErrorSnackBar(context, 'Por favor, escolha um tipo de transporte.');
      validateVehicle = true;
      notifyListeners();
      return;
    }

    validateVehicle = false;
    notifyListeners();

    if (travelerProvider.selectedTravelers.isEmpty) {
      _showErrorSnackBar(context, 'Adicione pelo menos um viajante.');
      validadeTravelers = true;
      notifyListeners();
      return;
    }

    validadeTravelers = false;
    notifyListeners();

    if (_destinations.isEmpty) {
      _showErrorSnackBar(context, 'A viagem precisa de pelo menos um destino.');
      validadeRoute = true;
      notifyListeners();
      return;
    }
    validadeRoute = false;
    notifyListeners();

    if (_destinations.any((d) => d.location == null)) {
      _showErrorSnackBar(
        context,
        'Todos os destinos devem ter um local preenchido.',
      );
      validadeRoute = true;
      notifyListeners();
      return;
    }
    validadeRoute = false;
    notifyListeners();

    for (int i = 1; i < _destinations.length; i++) {
      final prevDest = _destinations[i - 1];
      final currentDest = _destinations[i];

      if (prevDest.departureDate == null || currentDest.arrivalDate == null) {
        _showErrorSnackBar(
          context,
          'Por favor, preencha as datas de todos os destinos.',
        );
        return;
      }

      final isSameDay =
          prevDest.departureDate!.year == currentDest.arrivalDate!.year &&
          prevDest.departureDate!.month == currentDest.arrivalDate!.month &&
          prevDest.departureDate!.day == currentDest.arrivalDate!.day;

      if (!isSameDay) {
        final prevIndex = i;
        final currentIndex = i + 1;
        _showErrorSnackBar(
          context,
          'A data de início do destino $currentIndex deve ser a mesma da data de fim do destino $prevIndex.',
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tudo certo! Salvando sua viagem...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
