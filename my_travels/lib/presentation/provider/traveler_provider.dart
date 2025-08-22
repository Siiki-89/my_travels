import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';
import 'package:my_travels/l10n/app_localizations.dart';

class TravelerProvider with ChangeNotifier {
  final TravelerRepository _repository = TravelerRepository();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  bool _onPressed = false;
  bool get onPressed => _onPressed;

  void changeOnPressed() {
    _onPressed = !_onPressed;
    notifyListeners();
  }

  String _name = '';
  int? _age;
  File? _selectedImage;
  String? _errorMessage;
  List<Traveler> _travelers = [];
  bool _isLoading = false;
  int? _editingId;
  String _optionNow = '';
  final List<Traveler> _selectedTravelers = [];

  int? get editingId => _editingId;
  String get name => _name;
  String? get errorMessage => _errorMessage;
  int? get age => _age;
  File? get selectedImage => _selectedImage;
  List<Traveler> get travelers => _travelers;
  bool get isLoading => _isLoading;
  String get optionNow => _optionNow;
  List<Traveler> get selectedTravelers => _selectedTravelers;

  TravelerProvider() {
    loadTravelers();
  }

  void setName(String newName) => _name = newName;

  void setAge(String newAge) => _age = int.tryParse(newAge);

  void setImage(File? newImage) {
    _selectedImage = newImage;
    notifyListeners();
  }

  void setEditingId(int? id) {
    _editingId = id;
    notifyListeners();
  }

  void setOptionNow(String option) {
    _optionNow = option;
    notifyListeners();
  }

  bool isSelected(Traveler traveler) {
    return _selectedTravelers.any((t) => t.id == traveler.id);
  }

  void toggleTraveler(Traveler traveler) {
    final index = _selectedTravelers.indexWhere((t) => t.id == traveler.id);
    if (index != -1) {
      _selectedTravelers.removeAt(index);
    } else {
      _selectedTravelers.add(traveler);
    }
    notifyListeners();
  }

  void changeOptionNow(String valor) {
    if (_optionNow == valor) {
      _optionNow = '';
      resetFields();
    } else {
      _optionNow = valor;
      resetFields();
    }
    notifyListeners();
  }

  Future<void> loadTravelers([BuildContext? context]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _travelers = await _repository.getTravelers();
      debugPrint('Viajantes carregados: ${_travelers.length}');
    } catch (e) {
      final t = AppLocalizations.of(context!);
      _errorMessage = '${t?.errorLoadingTravelers} $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTraveler([BuildContext? context]) async {
    final t = context != null ? AppLocalizations.of(context) : null;
    _errorMessage = null;

    final name = nameController.text;
    final age = int.tryParse(ageController.text);

    if (name.trim().isEmpty) {
      _errorMessage = t?.nameRequiredError;
      notifyListeners();
      return;
    }
    if (age == null || age <= 0) {
      _errorMessage = t?.ageRequiredError;
      notifyListeners();
      return;
    }

    final newTraveler = Traveler(
      name: name,
      age: age,
      photoPath: _selectedImage?.path,
    );

    try {
      await _repository.insertTraveler(newTraveler);
      resetFields();
      await loadTravelers(context);
    } catch (e) {
      _errorMessage = '${t?.errorAddingTraveler} $e';
      notifyListeners();
    }
  }

  Future<void> deleteTraveler(int? id, [BuildContext? context]) async {
    final t = context != null ? AppLocalizations.of(context) : null;
    if (id == null) {
      _errorMessage = 'ID inválido';
      notifyListeners();
      return;
    }
    try {
      await _repository.deleteTraveler(id);
      debugPrint('Viajante deletado: $id');
      await loadTravelers(context);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '${t?.errorDeletingTraveler} $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> editTraveler([BuildContext? context]) async {
    final t = context != null ? AppLocalizations.of(context) : null;
    if (_editingId == null) return;

    final name = nameController.text;
    final age = int.tryParse(ageController.text);

    final updatedTraveler = Traveler(
      id: _editingId,
      name: name,
      age: age,
      photoPath: _selectedImage?.path,
    );

    try {
      await _repository.updateTraveler(updatedTraveler);
      resetFields();
      await loadTravelers(context);
    } catch (e) {
      _errorMessage = '${t?.errorUpdatingTraveler} $e';
    }
  }

  void resetFields() {
    nameController.clear();
    ageController.clear();
    _selectedImage = null;
    _errorMessage = null;
    _editingId = null;
    notifyListeners();
  }

  void prepareForEdit(Traveler traveler) {
    nameController.text = traveler.name;
    ageController.text = traveler.age.toString();
    _selectedImage = traveler.photoPath != null
        ? File(traveler.photoPath!)
        : null;
    _editingId = traveler.id;
    _errorMessage = null;
    notifyListeners();
  }
}
