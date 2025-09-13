// In lib/domain/use_cases/travel/save_travel_use_case.dart

import 'package:my_travels/data/entities/travel_entity.dart' as entity;
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/l10n/app_localizations.dart';

/// A use case for validating and saving a travel itinerary.
class SaveTravelUseCase {
  /// The repository that handles the data layer operations for travels.
  final TravelRepository _repository;

  /// Creates an instance of [SaveTravelUseCase].
  const SaveTravelUseCase(this._repository);

  /// Executes the business logic for validating and saving a travel.
  ///
  /// Throws a [TravelValidationException] if any business rule is violated.
  Future<void> call(entity.Travel travel, AppLocalizations l10n) async {
    // 1. General Validations (Cover, Transport, Travelers)
    if (travel.coverImagePath == null || travel.coverImagePath!.isEmpty) {
      throw InvalidCoverImageException(l10n.errorSelectCoverImage);
    }
    if (travel.vehicle == null || travel.vehicle!.isEmpty) {
      throw InvalidTransportException(l10n.errorChooseTransport);
    }
    if (travel.travelers.isEmpty) {
      throw InvalidTravelersException(l10n.errorAddOneTraveler);
    }

    // 2. Route Structure Validations
    if (travel.stopPoints.length < 2) {
      throw InvalidRouteException(l10n.errorMinTwoStops);
    }
    if (travel.stopPoints.any((p) => p.locationName.trim().isEmpty)) {
      throw InvalidRouteException(l10n.errorAllStopsNeedLocation);
    }
    // This check ensures that dates are not null for intermediate stops.
    if (travel.stopPoints
        .skip(1)
        .any((p) => p.arrivalDate == null || p.departureDate == null)) {
      throw InvalidRouteException(l10n.errorAllStopsNeedDates);
    }

    // 3. Route Timeline Validations
    for (int i = 1; i < travel.stopPoints.length; i++) {
      final currentStop = travel.stopPoints[i];

      // It's safe to use the ! operator here because the check above
      // already guarantees that these dates are not null for this part of the loop.
      final arrivalDate = currentStop.arrivalDate!;
      final departureDate = currentStop.departureDate!;

      final DateTime previousDepartureDate;
      if (i == 1) {
        previousDepartureDate = travel.startDate;
      } else {
        final previousStop = travel.stopPoints[i - 1];
        previousDepartureDate = previousStop.departureDate!;
      }

      // Normalizes dates to ignore time, ensuring comparison is day-level only.
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

      // Validation 1: Internal consistency of the stop point.
      if (departureDay.isBefore(arrivalDay)) {
        throw InvalidRouteException(l10n.errorDepartureBeforeArrival);
      }

      // Validation 2: Sequential consistency between stop points.
      if (arrivalDay.isBefore(previousDepartureDay)) {
        throw InvalidRouteException(l10n.errorArrivalBeforePreviousDeparture);
      }
    }

    // If all validations pass, insert into the repository.
    await _repository.insertTravel(travel);
  }
}
