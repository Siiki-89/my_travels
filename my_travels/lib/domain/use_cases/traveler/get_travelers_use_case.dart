import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';

/// A use case responsible for retrieving a list of all travelers.
class GetTravelersUseCase {
  /// The repository that handles the data layer operations for travelers.
  final TravelerRepository _repository;

  /// Creates an instance of [GetTravelersUseCase].
  const GetTravelersUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Returns a list of all [Traveler]s from the repository.
  Future<List<Traveler>> call() {
    return _repository.getTravelers();
  }
}
