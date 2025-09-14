import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/domain/use_cases/traveler/delete_traveler_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/get_travelers_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/save_traveler_use_case.dart';
import 'package:my_travels/l10n/app_localizations.dart';

class TravelerProvider with ChangeNotifier {
  // --- DEPENDÊNCIAS (Use Cases) ---
  final GetTravelersUseCase _getTravelersUseCase;
  final SaveTravelerUseCase _saveTravelerUseCase;
  final DeleteTravelerUseCase _deleteTravelerUseCase;

  // --- ESTADO DA UI ---
  bool _isLoading = true;
  List<Traveler> _travelers = [];
  String? _errorMessage;
  List<Traveler> _selectedTravelers =
      []; // Usado na tela de seleção de viajantes

  // --- ESTADO DO FORMULÁRIO (Para o Dialog de Adicionar/Editar) ---
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  File? _selectedImage;
  int? _editingId;

  // --- GETTERS (Para a UI acessar o estado) ---
  bool get isLoading => _isLoading;
  List<Traveler> get travelers => _travelers;
  String? get errorMessage => _errorMessage;
  List<Traveler> get selectedTravelers => _selectedTravelers;
  File? get selectedImage => _selectedImage;
  int? get editingId => _editingId;

  // Construtor que recebe o repositório para criar os Use Cases.
  // Isso é chamado de Injeção de Dependência.
  TravelerProvider(TravelerRepository repository)
    : _getTravelersUseCase = GetTravelersUseCase(repository),
      _saveTravelerUseCase = SaveTravelerUseCase(repository),
      _deleteTravelerUseCase = DeleteTravelerUseCase(repository) {
    // Inicia o carregamento dos dados assim que o provider é criado.
    loadTravelers(null);
  }

  // --- MÉTODOS QUE INTERAGEM COM OS USE CASES ---

  Future<void> loadTravelers(AppLocalizations? l10n) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _travelers = await _getTravelersUseCase();
    } catch (e) {
      _errorMessage = 'Erro ao carregar viajantes.';
      //debugPrint("Erro em loadTravelers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva (cria ou atualiza) um viajante.
  /// Lança `TravelerValidationException` em caso de falha de validação,
  /// que será tratada pela UI.
  Future<void> saveTraveler() async {
    final traveler = Traveler(
      id: _editingId,
      name: nameController.text,
      age:
          int.tryParse(ageController.text) ?? -1, // -1 para falhar na validação
      photoPath: _selectedImage?.path,
    );

    // O UseCase agora lida com a validação e o salvamento.
    // O try-catch será feito na UI para exibir o erro específico.
    //await _saveTravelerUseCase(traveler);

    // Após o sucesso, limpa os campos e recarrega a lista.
    resetFields();
    await loadTravelers(null);
  }

  Future<void> deleteTraveler(int id, BuildContext context) async {
    try {
      await _deleteTravelerUseCase(id);
      await loadTravelers(null);
    } catch (e) {
      _errorMessage = 'Erro ao deletar viajante.';
      _showErrorSnackBar(context, _errorMessage!);
      debugPrint("Erro em deleteTraveler: $e");
    }
  }

  // --- MÉTODOS QUE GERENCIAM A UI E O ESTADO DO FORMULÁRIO ---

  void prepareForEdit(Traveler traveler) {
    _editingId = traveler.id;
    nameController.text = traveler.name;
    ageController.text = traveler.age.toString();
    _selectedImage = traveler.photoPath != null
        ? File(traveler.photoPath!)
        : null;
    notifyListeners();
  }

  void resetFields() {
    _editingId = null;
    nameController.clear();
    ageController.clear();
    _selectedImage = null;
    notifyListeners();
  }

  void setImage(File? newImage) {
    _selectedImage = newImage;
    notifyListeners();
  }

  // Lógica para a seleção de viajantes para uma viagem
  bool isSelected(Traveler traveler) {
    return _selectedTravelers.any((t) => t.id == traveler.id);
  }

  void clearSelection() {
    _selectedTravelers.clear();
    notifyListeners();
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

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}
