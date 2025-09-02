import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';
import 'package:my_travels/domain/failures/failures.dart';

class SaveTravelerUseCase {
  SaveTravelerUseCase({required this.repository});
  final TravelerRepository repository;

  Future<int> call(Traveler traveler) async {
    if (traveler.name.trim().isEmpty) {
      throw ValidationException('O nome do participante é obrigatório.');
    }
    final age = traveler.age;
    if (age == null || age <= 0 || age > 120) {
      throw ValidationException('Por favor, insira uma idade válida.');
    }
    return repository.insertTraveler(traveler);
  }
}
