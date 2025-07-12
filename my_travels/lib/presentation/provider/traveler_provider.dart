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
  int? _editingId; 
  String _optionNow = ''; 


  int? get editingId => _editingId;
  String get name => _name;
  String? get errorMessage => _errorMessage;
  int? get age => _age;
  File? get selectedImage => _selectedImage;
  List<Traveler> get travelers => _travelers;
  bool get isLoading => _isLoading;
  String get optionNow => _optionNow;

  TravelerProvider() {
    loadTravelers();
  }


  void setName(String newName) {
    _name = newName;
  }

  void setAge(String newAge) {
    _age = int.tryParse(newAge);
  }

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

  Future<void> loadTravelers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _travelers = await _repository.getTravelers();
      debugPrint('Viajantes carregados: ${_travelers.length}');
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

    if (_name.trim().isEmpty) {
      _errorMessage = 'O nome do viajante é obrigatório.';
      notifyListeners();
      return;
    }
    if (_age == null || _age! <= 0) {
      _errorMessage = 'Precisa inserir uma idade válida.';
      notifyListeners();
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
      setOptionNow('');
      await loadTravelers();
    } catch (e) {
      _errorMessage = 'Erro ao adicionar viajante: $e';
      debugPrint('Erro ao adicionar viajante $e');
      notifyListeners();
    }
  }

  Future<void> deleteTraveler(int? id) async {
    if (id == null) {
      _errorMessage = 'ID do viajante para deletar é nulo.';
      notifyListeners();
      return;
    }
    try {
      await _repository.deleteTraveler(id);
      debugPrint('Viajante deletado: $id');
      await loadTravelers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao deletar viajante: $e';
      debugPrint('Erro ao deletar viajante $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> editTraveler(Traveler traveler) async {
    _errorMessage = null;

    if (traveler.id == null ||
        traveler.name.trim().isEmpty ||
        traveler.age == null ||
        traveler.age! <= 0) {
      _errorMessage = 'Dados inválidos para edição.';
      notifyListeners();
      return;
    }

    try {
      await _repository.updateTraveler(traveler);
      debugPrint('Viajante atualizado: ${traveler.name}');
      resetFields();
      setOptionNow('');
      await loadTravelers();
    } catch (e) {
      _errorMessage = 'Erro ao editar viajante: $e';
      debugPrint(_errorMessage!);
    } finally {
      notifyListeners();
    }
  }

  void resetFields() {
    _name = '';
    _age = null;
    _selectedImage = null;
    _errorMessage = null;
    _editingId = null;
    notifyListeners();
  }

  void prepareForEdit(Traveler traveler) {
    _name = traveler.name;
    _age = traveler.age;
    _selectedImage = traveler.photoPath != null
        ? File(traveler.photoPath!)
        : null;
    _editingId = traveler.id;
    _errorMessage = null;
    notifyListeners();
  }
}
