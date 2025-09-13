import 'package:my_travels/data/repository/travel_repository.dart';

/// A use case responsible for deleting a travel and its associated data.
class DeleteTravelUseCase {
  /// The repository that handles the data layer operations for travels.
  final TravelRepository _repository;

  /// Creates an instance of [DeleteTravelUseCase].
  const DeleteTravelUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Deletes a travel identified by its [travelId].
  Future<void> call(int travelId) {
    // The logic is simple: it just calls the delete method from the repository.
    // More complex business rules could be added here in the future.
    return _repository.deleteTravel(travelId);
  }
}
