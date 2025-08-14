import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';

class HomeProvider with ChangeNotifier {
  final TravelRepository _travelRepository = TravelRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _onPressed = false;
  bool get onPressed => _onPressed;

  // --- LÓGICA DE DADOS SIMPLIFICADA ---

  // Lista que guarda uma cópia mestre de TODAS as viagens
  List<Travel> _allTravels = [];

  // Lista que será efetivamente exibida na tela (pode ser a completa ou a filtrada)
  List<Travel> _filteredTravels = [];

  // A UI sempre vai ler desta lista.
  List<Travel> get travels => _filteredTravels;

  HomeProvider() {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTravels = await _travelRepository.getTravels();
      // Ao carregar, a lista a ser exibida é a lista completa.
      _filteredTravels = _allTravels;
      debugPrint('Viagens carregadas: ${_allTravels.length}');
    } catch (e) {
      print("Erro ao buscar viagens: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- LÓGICA DE BUSCA CORRIGIDA E SIMPLIFICADA ---
  void search(String input) {
    if (input.isEmpty) {
      // Se o campo de busca estiver vazio, mostramos todas as viagens.
      _filteredTravels = _allTravels;
    } else {
      // Caso contrário, filtramos a lista MESTRE (`_allTravels`)
      // e atualizamos a lista que a tela está vendo (`_filteredTravels`).
      _filteredTravels = _allTravels
          .where(
            (travel) =>
                travel.title.toLowerCase().contains(input.toLowerCase()),
          )
          .toList();
    }
    // Notifica a UI para se redesenhar com a lista atualizada.
    notifyListeners();
  }

  // Ação do botão animado (mantida)
  void changeOnPressed() {
    _onPressed = !_onPressed;
    notifyListeners();
  }
}
