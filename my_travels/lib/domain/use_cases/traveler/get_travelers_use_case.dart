// Em lib/domain/use_cases/traveler/get_travelers_use_case.dart

import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';

class GetTravelersUseCase {
  final TravelerRepository _repository;
  GetTravelersUseCase(this._repository);

  Future<List<Traveler>> call() {
    return _repository.getTravelers();
  }
}
