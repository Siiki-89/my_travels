import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';

class HomeProvider with ChangeNotifier {
  final TravelRepository _travelRepository = TravelRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Travel> _travels = [];
  List<Travel> get travels => _travels;

  Future<void> fetchTravels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _travels = await _travelRepository.getTravels();
    } catch (e) {
      print("Erro ao buscar viagens: $e");
      // Opcional: você pode adicionar uma variável de erro para mostrar na UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
