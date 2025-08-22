import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/data/entities/travel_entity.dart' as entity;
import 'package:my_travels/data/entities/stop_point_entity.dart' as entity;
import 'package:my_travels/data/entities/traveler_entity.dart' as entity;
import 'package:provider/provider.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/experience_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/model/transport_model.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';

class TravelProvider with ChangeNotifier {
  final TravelRepository _travelRepository = TravelRepository();

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

  TransportModel _transportSelect = TransportModel(label: '', lottieAsset: '');
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

    const String lottiePath = 'assets/images/lottie/typelocomotion/';

    _availableTransport.addAll([
      TransportModel(
        label: appLocalizations.vehicleCar,
        lottieAsset: '${lottiePath}car.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleMotorcycle,
        lottieAsset: '${lottiePath}motorcycle.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleBus,
        lottieAsset: '${lottiePath}bus.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleAirplane,
        lottieAsset: '${lottiePath}airplane.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleCruise,
        lottieAsset: '${lottiePath}cruise.json',
      ),
    ]);
  }

  final List<DestinationModel> _destinations = [DestinationModel(id: 0)];
  List<DestinationModel> get destinations => _destinations;

  int _nextId = 1;

  int? _editingIndex;
  int? get editingIndex => _editingIndex;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

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

    _editingIndex = -1;

    notifyListeners();
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

  final Map<int, bool> _destinationFirstTap = {};

  bool hasTappedOnce(int index) => _destinationFirstTap[index] ?? false;

  void registerFirstTap(int index) {
    _destinationFirstTap[index] = true;
    notifyListeners();
  }

  void resetFirstTap(int index) {
    _destinationFirstTap[index] = false;
    notifyListeners();
  }

  void resetAllTaps() {
    _destinationFirstTap.clear();
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

    final travelToSave = entity.Travel(
      title: titleController.text,
      startDate: _startData,
      endDate: _finalData,
      vehicle: _transportSelect.label,
      coverImagePath: _coverImage?.path,
      stopPoints: _destinations
          .where((d) => d.location != null)
          .map(
            (destinationModel) => entity.StopPoint(
              travelId: 0,
              stopOrder: _destinations.indexOf(destinationModel),
              locationName: destinationModel.location!.description,
              latitude: destinationModel.location!.lat,
              longitude: destinationModel.location!.long,
              description: destinationModel.description,
              arrivalDate: destinationModel.arrivalDate,
              departureDate: destinationModel.departureDate,
            ),
          )
          .toList(),
      travelers: travelerProvider.selectedTravelers
          .map(
            (travelerModel) =>
                entity.Traveler(id: travelerModel.id, name: travelerModel.name),
          )
          .toList(),
    );

    try {
      await _travelRepository.insertTravel(travelToSave);
      resetTravelForm(travelerProvider);
      await context.read<HomeProvider>().fetchTravels();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Viagem salva com sucesso no seu dispositivo!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Ocorreu um erro ao salvar a viagem.');
      print("Erro no Provider ao chamar o repositório: $e");
    }
  }

  void resetTravelForm(TravelerProvider travelerProvider) {
    travelerProvider.selectedTravelers.clear();
    titleController.clear();
    _coverImage = null;
    _startData = DateTime.now();
    _finalData = DateTime.now();
    _selectedExperiences.clear();
    _transportSelect = TransportModel(label: '', lottieAsset: '');
    _destinations.clear();
    _destinations.add(DestinationModel(id: 0));
    _nextId = 1;
    _editingIndex = 0;

    descriptionController.clear();
<<<<<<< HEAD
=======

>>>>>>> f8481637a2fcd724617e851112ef1152a4e5933c
    validateImage = false;
    validateVehicle = false;
    validadeTravelers = false;
    validadeRoute = false;

    notifyListeners();
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
