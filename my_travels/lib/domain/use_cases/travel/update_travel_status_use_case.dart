// Em lib/domain/use_cases/travel/update_travel_status_use_case.dart

import 'package:my_travels/data/repository/travel_repository.dart';

class UpdateTravelStatusUseCase {
  final TravelRepository _repository;
  UpdateTravelStatusUseCase(this._repository);

  Future<void> call({required int travelId, required bool isFinished}) {
    if (isFinished) {
      return _repository.markTravelAsFinished(travelId);
    } else {
      return _repository.markTravelAsUnfinished(travelId);
    }
  }
}
