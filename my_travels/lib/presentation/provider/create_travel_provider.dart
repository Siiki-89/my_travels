import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:my_travels/data/entities/stop_point_entity.dart' as entity;
import 'package:my_travels/data/entities/travel_entity.dart' as entity;
import 'package:my_travels/data/entities/traveler_entity.dart' as entity;
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/domain/use_cases/travel/save_travel_use_case.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/experience_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/model/transport_model.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/utils/experience_model.dart';
import 'package:my_travels/utils/transport_data.dart';

/// State manager for the travel creation screen.
class CreateTravelProvider with ChangeNotifier {
  final SaveTravelUseCase _saveTravelUseCase;

  /// Creates an instance of [CreateTravelProvider].
  CreateTravelProvider({SaveTravelUseCase? saveTravelUseCase})
    : _saveTravelUseCase =
          saveTravelUseCase ?? SaveTravelUseCase(TravelRepository());
  // -- Text Controllers --
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  // -- Main Form State --
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  File? _coverImage;
  TransportModel _selectedTransport = TransportModel(
    label: '',
    lottieAsset: '',
  );
  final List<ExperienceModel> _selectedExperiences = [];
  List<ExperienceModel> _availableExperiences = [];
  List<TransportModel> _availableTransports = [];
  List<DestinationModel> _destinations = [DestinationModel(id: 0)];

  // -- Destination Editing Control --
  int _nextId = 1;
  int? _editingIndex;
  DateTime? _tempArrivalDate;
  DateTime? _tempDepartureDate;
  final Map<int, bool> _destinationFirstTap = {};

  // -- UI Feedback State --
  String? _errorMessage;
  bool _saveSuccess = false;
  bool _isLoading = false;
  bool _showImageError = false;
  bool _showVehicleError = false;
  bool _showTravelersError = false;
  bool _showRouteError = false;

  // -- Flags to prevent multiple loads of static data --
  bool _experiencesLoaded = false;
  bool _vehiclesLoaded = false;

  // -- Getters for safe state exposure to the UI --
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get startDateString => _formatDate(_startDate);
  String get endDateString => _formatDate(_endDate);
  File? get coverImage => _coverImage;
  TransportModel get selectedTransport => _selectedTransport;
  List<DestinationModel> get destinations => _destinations;
  int? get editingIndex => _editingIndex;
  List<ExperienceModel> get selectedExperiences => _selectedExperiences;
  List<ExperienceModel> get availableExperiences => _availableExperiences;
  List<TransportModel> get availableTransports => _availableTransports;
  DateTime? get tempArrivalDate => _tempArrivalDate;
  DateTime? get tempDepartureDate => _tempDepartureDate;
  String get arrivalDateString =>
      _tempArrivalDate != null ? _formatDate(_tempArrivalDate!) : 'Select';
  String get departureDateString =>
      _tempDepartureDate != null ? _formatDate(_tempDepartureDate!) : 'Select';

  String? get errorMessage => _errorMessage;
  bool get saveSuccess => _saveSuccess;
  bool get isLoading => _isLoading;
  bool get showImageError => _showImageError;
  bool get showVehicleError => _showVehicleError;
  bool get showTravelersError => _showTravelersError;
  bool get showRouteError => _showRouteError;

  // -- Methods that modify the state --

  /// Updates the travel's cover image.
  void setImage(File? newImage) {
    _coverImage = newImage;
    notifyListeners();
  }

  /// Updates the start or end dates of the travel.
  void updateDate(DateTime newDate, {required bool isStartDate}) {
    if (isStartDate) {
      _startDate = newDate;
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    } else {
      _endDate = newDate;
    }
    notifyListeners();
  }

  /// Loads the list of available vehicles (only once).
  void loadAvailableVehicles(BuildContext context) {
    if (_vehiclesLoaded) return;
    _availableTransports = getAvailableVehicles(context);
    _vehiclesLoaded = true;
  }

  /// Loads the list of available experiences (only once).
  void loadAvailableExperiences(BuildContext context) {
    if (_experiencesLoaded) return;
    _availableExperiences = getAvailableExperiences(context);
    _experiencesLoaded = true;
  }

  /// Checks if a specific experience is in the selected list.
  bool isSelectedExperience(ExperienceModel experience) {
    return _selectedExperiences.contains(experience);
  }

  /// Toggles an experience in the selected list.
  void toggleExperience(ExperienceModel experience) {
    if (isSelectedExperience(experience)) {
      _selectedExperiences.remove(experience);
    } else {
      _selectedExperiences.add(experience);
    }
    notifyListeners();
  }

  /// Checks if a specific vehicle is the selected one.
  bool isSelectedVehicle(TransportModel transport) =>
      _selectedTransport.label == transport.label;

  /// Selects the vehicle for the travel.
  void selectVehicle(TransportModel transport) {
    _selectedTransport = transport;
    notifyListeners();
  }

  // -- Destination Management Methods --

  /// Adds a new destination to the list.
  void addDestination() {
    _destinations.add(DestinationModel(id: _nextId++));
    notifyListeners();
  }

  /// Updates the location of a destination being edited.
  void updateDestinationLocation(int index, LocationMapModel location) {
    if (index >= 0 && index < _destinations.length) {
      final destination = _destinations[index];
      _destinations[index] = destination.copyWith(
        location: location,
        description: location.description,
      );
      notifyListeners();
    }
  }

  /// Starts editing mode for a specific destination.
  void startEditing(int index) {
    _editingIndex = index;
    final destination = _destinations[index];
    descriptionController.text = destination.description ?? '';

    if (destination.arrivalDate != null) {
      _tempArrivalDate = destination.arrivalDate;
      _tempDepartureDate = destination.departureDate;
    } else {
      final DateTime previousDate = (index > 0)
          ? _destinations[index - 1].departureDate ?? _startDate
          : _startDate;
      _tempArrivalDate = previousDate;
      _tempDepartureDate = previousDate.add(const Duration(days: 1));
    }
    notifyListeners();
  }

  /// Saves the changes for a destination and exits editing mode.
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

  /// Updates the temporary arrival date during editing.
  void updateArrivalDate(DateTime date) {
    _tempArrivalDate = date;
    notifyListeners();
  }

  /// Updates the temporary departure date during editing.
  void updateDepartureDate(DateTime date) {
    _tempDepartureDate = date;
    notifyListeners();
  }

  /// Removes a destination from the list by its ID.
  void removeDestinationById(int id) {
    final indexToRemove = _destinations.indexWhere((d) => d.id == id);
    if (indexToRemove == -1) return;

    _destinations.removeAt(indexToRemove);
    if (indexToRemove == _editingIndex) {
      _editingIndex = null;
    }
    notifyListeners();
  }

  /// Checks if a destination has been tapped for the first time.
  bool hasTappedOnce(int index) => _destinationFirstTap[index] ?? false;

  /// Registers the first tap on a destination to trigger expansion.
  void registerFirstTap(int index) {
    _destinationFirstTap[index] = true;
    notifyListeners();
  }

  /// Resets the "first tap" state for a specific destination.
  void resetFirstTap(int index) {
    _destinationFirstTap.remove(index);
    notifyListeners();
  }

  /// Clears the "first tap" state for all destinations.
  void resetAllTaps() {
    _destinationFirstTap.clear();
    notifyListeners();
  }

  // -- Main Save Logic --

  /// Orchestrates the validation and saving of the travel.
  ///
  /// Updates internal state (_saveSuccess or _errorMessage) to which the UI must react.
  Future<void> saveTravel(
    TravelerProvider travelerProvider,
    HomeProvider homeProvider,
    AppLocalizations l10n,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _saveSuccess = false;
    _resetValidationFlags();
    notifyListeners();

    if (_editingIndex != null) concludeEditing();

    final travelToSave = _buildTravelEntity(travelerProvider);

    try {
      await _saveTravelUseCase.call(travelToSave, l10n);

      // On SUCCESS: update the success flag and trigger side effects.
      _saveSuccess = true;
      await homeProvider.fetchTravels(l10n);
      resetForm(travelerProvider);
    } on TravelValidationException catch (e) {
      _errorMessage = e.message;
      _handleValidationException(e);
    } catch (e) {
      _errorMessage = l10n.unexpectedErrorOnSave;
      // debugPrint("Generic error while saving travel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the form state completely after a successful save or cancellation.
  void resetForm(TravelerProvider travelerProvider) {
    travelerProvider.clearSelection();
    titleController.clear();
    descriptionController.clear();
    _coverImage = null;
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _selectedExperiences.clear();
    _selectedTransport = TransportModel(label: '', lottieAsset: '');
    _destinations = [DestinationModel(id: 0)];
    _nextId = 1;
    _editingIndex = null;
    _resetValidationFlags();
    _vehiclesLoaded = false;
    _experiencesLoaded = false;
    notifyListeners();
  }

  // -- Private Helper Methods --

  /// Builds the domain [Travel] entity from the provider's current state.
  entity.Travel _buildTravelEntity(TravelerProvider travelerProvider) {
    final validDestinations = _destinations
        .where((d) => d.location != null)
        .toList();
    final DateTime finalTravelDate =
        validDestinations.isNotEmpty &&
            validDestinations.last.departureDate != null
        ? validDestinations.last.departureDate!
        : _endDate;

    return entity.Travel(
      title: titleController.text,
      startDate: _startDate,
      endDate: finalTravelDate,
      vehicle: _selectedTransport.label,
      coverImagePath: _coverImage?.path,
      stopPoints: validDestinations
          .map(
            (dest) => entity.StopPoint(
              travelId: 0,
              stopOrder: _destinations.indexOf(dest),
              locationName: dest.location!.description,
              latitude: dest.location!.lat,
              longitude: dest.location!.long,
              description: dest.description,
              arrivalDate: dest.arrivalDate,
              departureDate: dest.departureDate,
            ),
          )
          .toList(),
      travelers: travelerProvider.selectedTravelers
          .map((t) => entity.Traveler(id: t.id, name: t.name))
          .toList(),
      isFinished: false,
    );
  }

  /// Sets the correct validation flag based on the exception type.
  void _handleValidationException(TravelValidationException e) {
    if (e is InvalidCoverImageException) _showImageError = true;
    if (e is InvalidTransportException) _showVehicleError = true;
    if (e is InvalidTravelersException) _showTravelersError = true;
    if (e is InvalidRouteException) _showRouteError = true;
  }

  /// Formats a date to the dd/MM/yyyy pattern.
  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  /// Resets all validation flags to their initial state.
  void _resetValidationFlags() {
    _showImageError = false;
    _showVehicleError = false;
    _showTravelersError = false;
    _showRouteError = false;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    titleController.dispose();
    super.dispose();
  }
}
