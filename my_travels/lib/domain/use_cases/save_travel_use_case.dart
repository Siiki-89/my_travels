// domain/use_cases/save_travel_use_case.dart

import 'package:my_travels/data/entities/travel_entity.dart' as entity;
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';

class SaveTravelUseCase {
  final TravelRepository _repository;

  SaveTravelUseCase(this._repository);

  /// Executa a lógica de validação e salvamento da viagem.
  /// Lança uma [TravelValidationException] se alguma regra de negócio for violada.
  Future<void> call(entity.Travel travel) async {
    // 1. Validações Gerais (Capa, Transporte, Viajantes)
    // ... (código anterior sem alterações)
    if (travel.coverImagePath == null || travel.coverImagePath!.isEmpty) {
      throw InvalidCoverImageException(
        'Por favor, selecione uma imagem de capa.',
      );
    }
    if (travel.vehicle!.isEmpty) {
      throw InvalidTransportException(
        'Por favor, escolha um tipo de transporte.',
      );
    }
    if (travel.travelers.isEmpty) {
      throw InvalidTravelersException(
        'Adicione pelo menos um viajante à viagem.',
      );
    }

    // 2. Validações da Rota (Estrutura)
    // ... (código anterior sem alterações)
    if (travel.stopPoints.length < 2) {
      throw InvalidRouteException(
        'A viagem deve ter pelo menos um ponto de partida e um destino.',
      );
    }
    if (travel.stopPoints.any((p) => p.locationName.isEmpty)) {
      throw InvalidRouteException(
        'Todos os destinos devem ter um local preenchido.',
      );
    }
    if (travel.stopPoints
        .skip(1)
        .any((p) => p.arrivalDate == null || p.departureDate == null)) {
      throw InvalidRouteException(
        'Todas as datas de chegada e partida dos destinos devem ser preenchidas.',
      );
    }

    // 3. Validações da Linha do Tempo da Rota
    for (int i = 1; i < travel.stopPoints.length; i++) {
      final currentStop = travel.stopPoints[i];

      final arrivalDate = currentStop.arrivalDate!;
      final departureDate = currentStop.departureDate!;

      final DateTime previousDepartureDate;
      if (i == 1) {
        previousDepartureDate = travel.startDate;
      } else {
        final previousStop = travel.stopPoints[i - 1];
        previousDepartureDate = previousStop.departureDate!;
      }

      // ### INÍCIO DA CORREÇÃO ###

      // Normaliza as datas para ignorar a hora, minuto e segundo.
      // Isso garante que a comparação seja feita apenas no nível do dia.
      final arrivalDay = DateTime(
        arrivalDate.year,
        arrivalDate.month,
        arrivalDate.day,
      );
      final departureDay = DateTime(
        departureDate.year,
        departureDate.month,
        departureDate.day,
      );
      final previousDepartureDay = DateTime(
        previousDepartureDate.year,
        previousDepartureDate.month,
        previousDepartureDate.day,
      );

      // ### FIM DA CORREÇÃO ###

      // Verificação 1: Consistência interna do destino.
      // Usa as datas normalizadas para a comparação.
      if (departureDay.isBefore(arrivalDay)) {
        throw InvalidRouteException(
          'No destino "${currentStop.locationName}", a data de partida não pode ser anterior à data de chegada.',
        );
      }

      // Verificação 2: Consistência sequencial entre destinos.
      // Usa as datas normalizadas para a comparação.
      if (arrivalDay.isBefore(previousDepartureDay)) {
        throw InvalidRouteException(
          'A chegada em "${currentStop.locationName}" não pode ser antes da partida do local anterior.',
        );
      }
    }

    // Se todas as validações passarem, insere no repositório
    await _repository.insertTravel(travel);
  }
}
