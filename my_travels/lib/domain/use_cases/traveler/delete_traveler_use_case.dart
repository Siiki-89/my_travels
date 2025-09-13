import 'package:my_travels/data/repository/traveler_repository.dart';

/// A use case responsible for deleting a traveler.
class DeleteTravelerUseCase {
  /// The repository that handles the data layer operations for travelers.
  final TravelerRepository _repository;

  /// Creates an instance of [DeleteTravelerUseCase].
  const DeleteTravelerUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Deletes a traveler identified by their [travelerId].
  Future<void> call(int travelerId) async {
    await _repository.deleteTraveler(travelerId);
  }
}
