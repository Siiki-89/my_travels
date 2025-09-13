import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/l10n/app_localizations.dart';

/// A use case for validating and then saving (inserting or updating) a traveler.
class SaveTravelerUseCase {
  /// The repository that handles the data layer operations for travelers.
  final TravelerRepository _repository;

  /// Creates an instance of [SaveTravelerUseCase].
  const SaveTravelerUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Validates the [traveler]'s data against business rules. If valid, it
  /// updates the traveler if an ID exists, otherwise it inserts a new one.
  /// Throws an [InvalidTravelerException] if validation fails.
  Future<void> call(Traveler traveler, AppLocalizations l10n) async {
    // Rule 1: Name cannot be empty and must be between 3 and 50 characters.
    final trimmedName = traveler.name.trim();
    if (trimmedName.length < 3) {
      throw InvalidTravelerException(l10n.errorTravelerNameTooShort);
    }
    if (trimmedName.length > 50) {
      throw InvalidTravelerException(l10n.errorTravelerNameTooLong);
    }

    // Rule 2: If age is provided, it must be a valid number between 0 and 120.
    if (traveler.age != null && (traveler.age! < 0 || traveler.age! > 120)) {
      throw InvalidTravelerException(l10n.errorTravelerAgeInvalid);
    }

    // If the traveler already has an ID, update. Otherwise, insert.
    if (traveler.id != null) {
      await _repository.updateTraveler(traveler);
    } else {
      await _repository.insertTraveler(traveler);
    }
  }
}
