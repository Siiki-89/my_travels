import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';

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
  bool _isLoading = true;
  List<Traveler> _travelers = [];
  String? _errorMessage; // For background errors
  final List<Traveler> _selectedTravelers = [];

  // -- Form State (For the Add/Edit Dialog) --
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  File? _selectedImage;
  int? _editingId;

  // -- Getters --
  bool get isLoading => _isLoading;
  List<Traveler> get travelers => _travelers;
  String? get errorMessage => _errorMessage;
  List<Traveler> get selectedTravelers => _selectedTravelers;
  File? get selectedImage => _selectedImage;
  int? get editingId => _editingId;

  /// Creates an instance of [TravelerProvider].
  ///
  /// Use cases are injected for testability and separation of concerns.
  TravelerProvider({
    required GetTravelersUseCase getTravelersUseCase,
    required SaveTravelerUseCase saveTravelerUseCase,
    required DeleteTravelerUseCase deleteTravelerUseCase,
  }) : _getTravelersUseCase = getTravelersUseCase,
       _saveTravelerUseCase = saveTravelerUseCase,
       _deleteTravelerUseCase = deleteTravelerUseCase {
    // Starts loading data as soon as the provider is created.
    loadTravelers();
  }

  // --- Methods that interact with Use Cases ---

  /// Loads the list of all travelers from the repository.
  Future<void> loadTravelers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _travelers = await _getTravelersUseCase();
    } catch (e) {
      // debugPrint("Error in loadTravelers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves (creates or updates) a traveler and handles UI feedback.
  Future<void> saveTraveler(AppLocalizations l10n) async {
    final travelerToSave = Traveler(
      id: _editingId,
      name: nameController.text,
      age: int.tryParse(ageController.text),
      photoPath: _selectedImage?.path,
    );

    try {
      await _saveTravelerUseCase(travelerToSave, l10n);

      resetFields();
      await loadTravelers();
    } on InvalidTravelerException catch (e) {
      throw e; // A UI trata a exibição do erro
    } catch (e) {
      throw Exception('Error saving traveler');
    }
  }

  /// Deletes a traveler by their ID and handles UI feedback.
  Future<void> deleteTraveler(int id, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _deleteTravelerUseCase(id);
      _travelers.removeWhere((t) => t.id == id);
      notifyListeners();
      if (context.mounted)
        _showSuccessSnackBar(context, l10n.travelerDeletedSuccess);
    } catch (e) {
      if (context.mounted)
        _showErrorSnackBar(context, l10n.errorDeletingTraveler);
      // debugPrint('Error in deleteTraveler: $e');
    }
  }

  // --- Methods that manage UI and Form state ---

  /// Prepares the provider for editing a traveler.
  void prepareForEdit(Traveler traveler) {
    _editingId = traveler.id;
    nameController.text = traveler.name;
    ageController.text = traveler.age?.toString() ?? '';
    _selectedImage = traveler.photoPath != null
        ? File(traveler.photoPath!)
        : null;
    notifyListeners();
  }

  /// Resets form fields and editing state.
  void resetFields() {
    _editingId = null;
    nameController.clear();
    ageController.clear();
    _selectedImage = null;
    notifyListeners();
  }

  /// Sets the selected image for the traveler form.
  void setImage(File? newImage) {
    _selectedImage = newImage;
    notifyListeners();
  }

  /// Clears all selected travelers.
  void clearSelection() {
    _selectedTravelers.clear();
    notifyListeners();
  }

  /// Toggles a traveler's selection state.
  void toggleTraveler(Traveler traveler) {
    if (isSelected(traveler)) {
      _selectedTravelers.removeWhere((t) => t.id == traveler.id);
    } else {
      _selectedTravelers.add(traveler);
    }
    notifyListeners();
  }

  /// Returns true if the traveler is currently selected.
  bool isSelected(Traveler traveler) {
    return _selectedTravelers.any((t) => t.id == traveler.id);
  }

  /// Displays an error message using a snackbar.
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  /// Displays a success message using a snackbar.
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }
}
