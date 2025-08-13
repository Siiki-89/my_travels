import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';

class HomeProvider with ChangeNotifier {
  final TravelRepository _travelRepository = TravelRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _onPressed = false;
  bool get onPressed => _onPressed;

  void changeOnPressed() {
    _onPressed = !_onPressed;
    notifyListeners();
  }

  List<Travel> _travels = [];
  List<Travel> get travels => _searchVisible ? _filterTravels : _travels;

  List<Travel> _filterTravels = [];
  List<Travel> get filterTravels => _filterTravels;

  bool _searchVisible = false;
  bool get searchVisible => _searchVisible;

  void initSearch() {
    _searchVisible = true;
    _filterTravels = _travels;
    notifyListeners();
  }

  void search(String input) {
    _filterTravels = _travels
        .where(
          (travel) => travel.title.toLowerCase().contains(input.toLowerCase()),
        )
        .toList();
    notifyListeners();
  }

  void cancelSearch() {
    _searchVisible = false;
    _filterTravels = [];
    notifyListeners();
  }

  HomeProvider() {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _travels = await _travelRepository.getTravels();
      debugPrint('Viagens carregadas: ${_travels.length}');
    } catch (e) {
      print("Erro ao buscar viagens: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
