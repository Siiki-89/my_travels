// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get appName => 'My Travels';

  @override
  String get users => 'Travelers';

  @override
  String get addTraveler => 'Add Traveler';

  @override
  String get travelerNameHint => 'Traveler Name';

  @override
  String get ageHint => 'Age';

  @override
  String get nameRequiredError => 'Traveler name is required.';

  @override
  String get ageRequiredError => 'Please enter a valid age.';

  @override
  String get travelerAddedSuccess => 'Traveler added successfully!';

  @override
  String get travelerUpdatedSuccess => 'Traveler updated successfully!';

  @override
  String get travelerDeletedSuccess => 'Traveler deleted!';

  @override
  String get errorAddingTraveler => 'Error adding traveler: ';

  @override
  String get errorUpdatingTraveler => 'Error updating traveler: ';

  @override
  String get errorDeletingTraveler => 'Error deleting traveler: ';

  @override
  String get errorLoadingTravelers => 'Error loading travelers: ';

  @override
  String get noTravelersRegistered => 'No travelers registered.';

  @override
  String get confirmDeletionTitle => 'Confirm Deletion';

  @override
  String confirmDeletionContent(String travelerName) {
    return 'Are you sure you want to delete $travelerName?';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get saveButton => 'Save';

  @override
  String get editButton => 'Edit';

  @override
  String get clearButton => 'Clear';

  @override
  String get settings => 'Settings';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Activate or deactivate dark theme';

  @override
  String get home => 'Home';
}
