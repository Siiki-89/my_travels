import 'package:my_travels/data/repository/travel_repository.dart';

/// A use case responsible for updating the finished status of a travel.
class UpdateTravelStatusUseCase {
  /// The repository that handles the data layer operations for travels.
  final TravelRepository _repository;

  /// Creates an instance of [UpdateTravelStatusUseCase].
  const UpdateTravelStatusUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Marks a travel, identified by [travelId], as either finished or unfinished
  /// based on the [isFinished] flag.
  Future<void> call({required int travelId, required bool isFinished}) {
    if (isFinished) {
      return _repository.markTravelAsFinished(travelId);
    } else {
      return _repository.markTravelAsUnfinished(travelId);
    }
  }
}
