// Em lib/domain/use_cases/traveler/save_traveler_use_case.dart

import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';

class SaveTravelerUseCase {
  final TravelerRepository _repository;
  SaveTravelerUseCase(this._repository);

  Future<void> call(Traveler traveler) async {
    // Regra 1: O nome não pode ser vazio e deve ter entre 3 e 50 caracteres.
    if (traveler.name.trim().length < 3) {
      throw InvalidTravelerDataException(
        'O nome deve ter pelo menos 3 caracteres.',
      );
    }
    if (traveler.name.trim().length > 50) {
      throw InvalidTravelerDataException(
        'O nome não pode exceder 50 caracteres.',
      );
    }

    // Regra 2: A idade deve ser um número válido entre 0 e 120.
    if (traveler.age! < 0 || traveler.age! > 120) {
      throw InvalidTravelerDataException(
        'Por favor, insira uma idade válida (0-120).',
      );
    }

    // Se o viajante já tem um ID, atualiza. Senão, insere.
    if (traveler.id != null) {
      await _repository.updateTraveler(traveler);
    } else {
      await _repository.insertTraveler(traveler);
    }
  }
}
