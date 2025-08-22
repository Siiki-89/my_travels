import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';

class HomeProvider with ChangeNotifier {
  final TravelRepository _travelRepository = TravelRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _onPressed = false;
  bool get onPressed => _onPressed;

  List<Travel> _allTravels = [];

  List<Travel> _filteredTravels = [];

  List<Travel> get travels => _filteredTravels;

  HomeProvider() {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTravels = await _travelRepository.getTravels();

      _filteredTravels = _allTravels;
      debugPrint('Viagens carregadas: ${_allTravels.length}');
    } catch (e) {
      print("Erro ao buscar viagens: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String input) {
    if (input.isEmpty) {
      _filteredTravels = _allTravels;
    } else {
      _filteredTravels = _allTravels
          .where(
            (travel) =>
                travel.title.toLowerCase().contains(input.toLowerCase()),
          )
          .toList();
    }

    notifyListeners();
  }

  void changeOnPressed() {
    _onPressed = !_onPressed;
    notifyListeners();
  }
}
