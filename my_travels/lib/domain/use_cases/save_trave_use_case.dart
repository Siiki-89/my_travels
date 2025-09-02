import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/domain/failures/failures.dart';

class SaveTravelUseCase {
  SaveTravelUseCase({required this.travelRepository});
  final TravelRepository travelRepository;

  Future<void> call(Travel travel) async {
    if (travel.title.trim().length < 3) {
      throw ValidationException('O título deve ter pelo menos 3 caracteres.');
    }
    if (travel.coverImagePath == null || travel.coverImagePath!.isEmpty) {
      throw ValidationException('Por favor, selecione uma imagem de capa.');
    }
    if (travel.vehicle == null || travel.vehicle!.isEmpty) {
      throw ValidationException('Por favor, escolha um tipo de transporte.');
    }
    if (travel.stopPoints.isEmpty ||
        travel.stopPoints.any((p) => p.locationName.isEmpty)) {
      throw ValidationException(
        'Todos os destinos devem ter um local preenchido.',
      );
    }

    await travelRepository.insertTravel(travel);
  }
}
