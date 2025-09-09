import 'package:flutter/foundation.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';

class HomeProvider with ChangeNotifier {
  final TravelRepository _repository = TravelRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool onPressed = false;

  // Lista principal que guarda todas as viagens do banco
  List<Travel> _allTravels = [];

  // Listas filtradas para a UI
  List<Travel> ongoingTravels = [];
  List<Travel> completedTravels = [];

  // Getter para a lista completa (usado na UI para checar se há alguma viagem)
  List<Travel> get allTravels => _allTravels;

  // Getter para a busca (combina as duas listas para a UI)
  List<Travel> get travels => [...ongoingTravels, ...completedTravels];

  HomeProvider() {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allTravels = await _repository.getTravels();
      // Filtra e separa as viagens nas listas corretas
      _filterAndSeparateTravels(_allTravels);
    } catch (e) {
      debugPrint("Erro ao buscar viagens: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      // Se a busca está vazia, mostra todas as viagens
      _filterAndSeparateTravels(_allTravels);
    } else {
      // Filtra a lista principal com base na busca
      final filtered = _allTravels.where((travel) {
        return travel.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
      // Separa os resultados da busca nas listas de "em andamento" e "concluídas"
      _filterAndSeparateTravels(filtered);
    }
    notifyListeners();
  }

  // Em lib/presentation/provider/home_provider.dart

  void _filterAndSeparateTravels(List<Travel> travelsToFilter) {
    ongoingTravels.clear();
    completedTravels.clear();

    // A lógica agora é muito mais direta:
    for (final travel in travelsToFilter) {
      if (travel.isFinished) {
        // Se a viagem está marcada como finalizada, vai para a lista de concluídas.
        completedTravels.add(travel);
      } else {
        // Caso contrário, ela está em andamento.
        ongoingTravels.add(travel);
      }
    }
  }

  void changeOnPressed() {
    onPressed = !onPressed;
    notifyListeners();
  }
}
