// Em lib/domain/use_cases/travel/delete_travel_use_case.dart

import 'package:my_travels/data/repository/travel_repository.dart';

class DeleteTravelUseCase {
  final TravelRepository _repository;
  DeleteTravelUseCase(this._repository);

  Future<void> call(int travelId) {
    // A lógica é simples: apenas chama o método de deletar do repositório.
    // Regras de negócio mais complexas poderiam ser adicionadas aqui no futuro.
    return _repository.deleteTravel(travelId);
  }
}
