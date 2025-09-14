import 'package:flutter/foundation.dart';
import 'package:my_travels/l10n/app_localizations.dart';

import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';

/// Manages the state for the home screen.
class HomeProvider with ChangeNotifier {
  final TravelRepository _repository;

  /// Creates an instance of [HomeProvider].
  HomeProvider({TravelRepository? repository})
    : _repository = repository ?? TravelRepository() {
    fetchTravels(null);
  }

  // -- State --
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialLoadStarted = false;

  List<Travel> _allTravels = [];
  List<Travel> _ongoingTravels = [];
  List<Travel> _completedTravels = [];

  // -- Getters --
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Travel> get allTravels => _allTravels;
  List<Travel> get ongoingTravels => _ongoingTravels;
  List<Travel> get completedTravels => _completedTravels;

  /// Kicks off the initial fetch for travels, ensuring it only runs once.
  void fetchTravelsIfNeeded(AppLocalizations l10n) {
    if (_isInitialLoadStarted) return;
    _isInitialLoadStarted = true;
    fetchTravels(l10n);
  }

  /// Fetches all travels from the repository and filters them.
  Future<void> fetchTravels(AppLocalizations? l10n) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTravels = await _repository.getTravels();
      _filterAndSeparateTravels(_allTravels);
    } catch (e) {
      _errorMessage = l10n?.errorLoadingTravels;
      // debugPrint('Error fetching travels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters the travel lists based on a search query.
  void search(String query) {
    final travelsToFilter = query.isEmpty
        ? _allTravels
        : _allTravels.where((travel) {
            return travel.title.toLowerCase().contains(query.toLowerCase());
          }).toList();

    _filterAndSeparateTravels(travelsToFilter);
    notifyListeners();
  }

  /// Separates a given list of travels into ongoing and completed lists.
  void _filterAndSeparateTravels(List<Travel> travelsToFilter) {
    _ongoingTravels = travelsToFilter.where((t) => !t.isFinished).toList();
    _completedTravels = travelsToFilter.where((t) => t.isFinished).toList();
  }
}
