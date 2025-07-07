import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';

class TravelerProvider with ChangeNotifier {
  final TravelerRepository _repository = TravelerRepository();
  String _name = '';
  int? _age;
  File? _selectedImage;
  String? _errorMessage;
  List<Traveler> _travelers = [];
  bool _isLoading = false;

  String get name => _name;
  String? get errorMessage => _errorMessage;
  int? get age => _age;
  File? get selectedImage => _selectedImage;
  List<Traveler> get travelers => _travelers;
  bool get isLoading => _isLoading;

  void setName(String newName) {
    _name = newName;
  }

  void setAge(String newAge) {
    _age = int.tryParse(newAge) ?? 0;
  }

  void setImage(File newImage) {
    _selectedImage = newImage;
    notifyListeners();
  }

  Future<void> loadTravelers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _travelers = await _repository.getTravelers();
    } catch (e) {
      _errorMessage = 'Erro ao carregar viajantes: $e';
      debugPrint('Erro ao carregar viajantes $e 🛑');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTraveler() async {
    _errorMessage = null;
    notifyListeners();

    if (_name.isEmpty) {
      _errorMessage = 'O nome do viajante é obrigatório.';
      debugPrint('Nome do viajante não pode ser vazio.');
      return;
    }
    if (_age == null) {
      _errorMessage = 'Precisa inserir uma idade.';
      debugPrint('Precisa inserir uma idade.');
      return;
    }

    final newTraveler = Traveler(
      name: _name,
      age: _age,
      photoPath: _selectedImage?.path,
    );

    try {
      await _repository.insertTraveler(newTraveler);
      debugPrint('Viajante foi salvo com sucesso: ${newTraveler.name} 🛑');
      resetFields();
    } catch (e) {
      _errorMessage = 'Erro ao adicionar viajante: $e';
      debugPrint('Erro ao adicionar viajante $e');
      notifyListeners();
    }
  }

  void resetFields() {
    _name = '';
    _age = 0;
    _selectedImage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
