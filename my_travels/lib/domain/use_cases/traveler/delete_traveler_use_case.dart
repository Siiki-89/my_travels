import 'package:my_travels/data/repository/traveler_repository.dart';

class DeleteTravelerUseCase {
  final TravelerRepository _repository;
  DeleteTravelerUseCase(this._repository);

  Future<void> call(int travelerId) async {
    await _repository.deleteTraveler(travelerId);
  }
}
