import 'dart:io';

import 'package:my_travels/l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/domain/use_cases/traveler/delete_traveler_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/get_travelers_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/save_traveler_use_case.dart';

/// Manages the state for traveler data, including fetching, saving, deleting,
/// and managing selections for trips.
class TravelerProvider with ChangeNotifier {
  // -- Dependencies (Use Cases) --
  final GetTravelersUseCase _getTravelersUseCase;
  final SaveTravelerUseCase _saveTravelerUseCase;
  final DeleteTravelerUseCase _deleteTravelerUseCase;

  // -- UI State --
  bool _isLoading = false;
  List<Traveler> _travelers = [];
  String? _errorMessage;
  final List<Traveler> _selectedTravelers = [];
  bool _saveSuccess = false;
  bool _deleteSuccess = false;

  // -- Form State (For the Add/Edit Dialog) --
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  File? _selectedImage;
  int? _editingId;

  // -- Internal Control --
  bool _isInitialLoadAttempted = false;

  // -- Getters --
  bool get isLoading => _isLoading;
  List<Traveler> get travelers => _travelers;
  String? get errorMessage => _errorMessage;
  List<Traveler> get selectedTravelers => _selectedTravelers;
  File? get selectedImage => _selectedImage;
  int? get editingId => _editingId;
  bool get saveSuccess => _saveSuccess;
  bool get deleteSuccess => _deleteSuccess;

  /// Creates an instance of [TravelerProvider].
  ///
  /// Use cases are injected for testability and separation of concerns.
  TravelerProvider({
    required GetTravelersUseCase getTravelersUseCase,
    required SaveTravelerUseCase saveTravelerUseCase,
    required DeleteTravelerUseCase deleteTravelerUseCase,
  }) : _getTravelersUseCase = getTravelersUseCase,
       _saveTravelerUseCase = saveTravelerUseCase,
       _deleteTravelerUseCase = deleteTravelerUseCase;

  // --- Methods that interact with Use Cases ---

  /// Kicks off the initial fetch for travelers, ensuring it only runs once.
  void loadTravelersIfNeeded(AppLocalizations l10n) {
    if (_isInitialLoadAttempted) return;
    _isInitialLoadAttempted = true;
    loadTravelers(l10n);
  }

  /// Loads the list of all travelers from the repository.
  Future<void> loadTravelers(AppLocalizations l10n) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _travelers = await _getTravelersUseCase();
    } catch (e) {
      _errorMessage = l10n.errorLoadingTravelers;
      // debugPrint('Error in loadTravelers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves (creates or updates) a traveler.
  ///
  /// This method is designed to re-throw [InvalidTravelerException] on validation
  /// failure, which should be caught by the UI to display specific error messages.
  Future<void> saveTraveler(AppLocalizations l10n) async {
    _isLoading = true;
    _saveSuccess = false;
    _errorMessage = null;
    notifyListeners();

    final travelerToSave = Traveler(
      id: _editingId,
      name: nameController.text,
      age: int.tryParse(ageController.text), // Use Case handles validation
      photoPath: _selectedImage?.path,
    );

    try {
      await _saveTravelerUseCase(travelerToSave, l10n);
      _saveSuccess = true;
      resetFields();
      await loadTravelers(l10n); // Reloads list on success
    } on InvalidTravelerException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      throw e; // Re-throw for the UI to catch and show the specific message
    } catch (e) {
      _errorMessage = _editingId != null
          ? l10n.errorUpdatingTraveler
          : l10n.errorAddingTraveler;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a traveler by their ID.
  Future<void> deleteTraveler(int id, AppLocalizations l10n) async {
    _deleteSuccess = false;
    _errorMessage = null;

    try {
      await _deleteTravelerUseCase(id);
      _deleteSuccess = true;
      await loadTravelers(l10n);
    } catch (e) {
      _errorMessage = l10n.errorDeletingTraveler;
      // debugPrint('Error in deleteTraveler: $e');
      notifyListeners();
    }
  }

  // --- Methods that manage UI and Form state ---

  /// Prepares the form for editing an existing traveler.
  void prepareForEdit(Traveler traveler) {
    _editingId = traveler.id;
    nameController.text = traveler.name;
    ageController.text = traveler.age?.toString() ?? '';
    _selectedImage = traveler.photoPath != null
        ? File(traveler.photoPath!)
        : null;
    notifyListeners();
  }

  /// Resets the form fields to their initial state.
  void resetFields() {
    _editingId = null;
    nameController.clear();
    ageController.clear();
    _selectedImage = null;
    notifyListeners();
  }

  /// Sets the selected image for the traveler's photo.
  void setImage(File? newImage) {
    _selectedImage = newImage;
    notifyListeners();
  }

  /// Clears the list of travelers selected for a trip.
  void clearSelection() {
    _selectedTravelers.clear();
    notifyListeners();
  }

  /// Checks if a specific traveler is currently selected.
  bool isSelected(Traveler traveler) {
    return _selectedTravelers.any((t) => t.id == traveler.id);
  }

  /// Adds or removes a traveler from the selection list.
  void toggleTraveler(Traveler traveler) {
    final index = _selectedTravelers.indexWhere((t) => t.id == traveler.id);
    if (index != -1) {
      _selectedTravelers.removeAt(index);
    } else {
      _selectedTravelers.add(traveler);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }
}
