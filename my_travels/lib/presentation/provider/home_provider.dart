import 'package:flutter/foundation.dart';
import 'package:my_travels/l10n/app_localizations.dart';

import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';

/// Manages the state for the home screen.
///
/// Responsible for fetching, filtering, and providing the list of travels
/// to be displayed on the UI.
class HomeProvider with ChangeNotifier {
  final TravelRepository _repository;

  /// Creates an instance of [HomeProvider].
  ///
  /// Dependencies are injected via the constructor for better testability.
  HomeProvider({required TravelRepository repository})
    : _repository = repository;

  // -- State --
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialLoadAttempted = false;

  /// The master list that holds all travels fetched from the repository.
  List<Travel> _allTravels = [];

  /// Filtered list for travels that are not finished.
  List<Travel> _ongoingTravels = [];

  /// Filtered list for travels that are marked as finished.
  List<Travel> _completedTravels = [];

  // -- Getters --

  /// Whether the provider is currently fetching data.
  bool get isLoading => _isLoading;

  /// A message describing the last error that occurred, if any.
  String? get errorMessage => _errorMessage;

  /// Returns the complete list of travels (unfiltered).
  List<Travel> get allTravels => _allTravels;

  /// Returns the list of ongoing travels.
  List<Travel> get ongoingTravels => _ongoingTravels;

  /// Returns the list of completed travels.
  List<Travel> get completedTravels => _completedTravels;

  // -- Methods --

  /// Kicks off the initial fetch for travels, ensuring it only runs once.
  /// This should be called from the UI.
  void fetchTravelsIfNeeded(AppLocalizations l10n) {
    if (_isInitialLoadAttempted) return;
    _isInitialLoadAttempted = true;
    fetchTravels(l10n);
  }

  /// Fetches all travels from the repository and filters them into appropriate lists.
  Future<void> fetchTravels(AppLocalizations l10n) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTravels = await _repository.getTravels();
      _filterAndSeparateTravels(_allTravels);
    } catch (e) {
      _errorMessage = l10n.errorLoadingTravels;
      // debugPrint('Error fetching travels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters the displayed travel lists based on a search query.
  void search(String query) {
    final travelsToFilter = query.isEmpty
        ? _allTravels
        : _allTravels.where((travel) {
            return travel.title.toLowerCase().contains(query.toLowerCase());
          }).toList();

    _filterAndSeparateTravels(travelsToFilter);
    notifyListeners();
  }

  /// A private helper to separate a list of travels into ongoing and completed lists.
  void _filterAndSeparateTravels(List<Travel> travelsToFilter) {
    _ongoingTravels = travelsToFilter.where((t) => !t.isFinished).toList();
    _completedTravels = travelsToFilter.where((t) => t.isFinished).toList();
  }
}
