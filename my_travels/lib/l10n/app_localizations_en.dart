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

  @override
  String get add => 'Add';

  @override
  String get travelAddTitle => 'Trip title';

  @override
  String get travelAddStartJourneyDateText => 'Start of the journey';

  @override
  String get travelAddStart => 'Start';

  @override
  String get travelAddFinal => 'End';

  @override
  String get travelAddTypeLocomotion => 'Type of vehicle';

  @override
  String get vehicleAirplane => 'Airplane';

  @override
  String get vehicleBus => 'Bus';

  @override
  String get vehicleCar => 'Car';

  @override
  String get vehicleCruise => 'Cruise';

  @override
  String get vehicleMotorcycle => 'Motorcycle';

  @override
  String get travelAddTrip => 'Travel route';

  @override
  String get travelAddStartintPoint => 'Choose starting point...';

  @override
  String get travelAddFinalPoint => 'Inform the destination ';

  @override
  String get travelAddDecriptionText => 'What will you do here?';

  @override
  String get travelAddPointButton => 'Save destination';

  @override
  String get travelAddTypeInterest => 'Group\'s points of interest';

  @override
  String get experienceTitle => 'Choose interests';

  @override
  String get experiencePark => 'Park';

  @override
  String get experienceBar => 'Bar';

  @override
  String get experienceCulinary => 'Culinary';

  @override
  String get experienceHistoric => 'Historic Place';

  @override
  String get experienceNature => 'Nature';

  @override
  String get experienceCulture => 'Cultural';

  @override
  String get experienceShow => 'Show';

  @override
  String get travelerToTravelTitle => 'Choose travels';

  @override
  String get mapAppBarTitle => 'Route';

  @override
  String get noTravelersTitle => 'Your Traveler\'s Catalog';

  @override
  String get noTravelersSubtitle => 'Add friends and family here...';

  @override
  String get travelerManagementHint => 'Manage travelers here. Saved people can be easily added to your future trips.';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get areYouSureYouWantToDelete => 'Are you sure you want to delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noTravelsTitle => 'No trips recorded';

  @override
  String get noTravelsSubtitle => 'Start by adding a destination and build your travel catalog.';

  @override
  String get travelManagementHint => 'Manage all your trips here. They will be saved and can be viewed or edited anytime.';

  @override
  String get updateHint => 'Update';

  @override
  String get enterName => 'Please enter a name.';

  @override
  String get enterValidNumber => 'Please enter a valid number.';

  @override
  String get enterAge => 'Please enter an age.';

  @override
  String get homeSearchHint => 'Search by title...';

  @override
  String get homeButtonExplore => 'Explore';

  @override
  String get ageBelowZero => 'Age must be greater than or equal to 0.';

  @override
  String get ageAboveNormal => 'Age above normal.';

  @override
  String get noSearchResults => 'No trips found with that name.';

  @override
  String get ongoingTravels => 'Ongoing travels:';

  @override
  String get completedTravels => 'Completed travels:';

  @override
  String get noOngoingTravels => 'No ongoing travels.';

  @override
  String get noCompletedTravels => 'You haven\'t completed any travels yet.';

  @override
  String get clearFormTitle => 'Clear Form';

  @override
  String get clearFormContent => 'Are you sure you would like to clear all the data?';

  @override
  String get clearFormConfirm => 'Clear';

  @override
  String get errorCommentEmpty => 'Please, type something.';

  @override
  String get errorCommentTooLong => 'The comment cannot be longer than 280 characters.';

  @override
  String get errorSelectAuthor => 'Please, select the author of the comment.';

  @override
  String get errorLinkCommentToLocation => 'Please, link the comment to a location on the trip.';

  @override
  String get errorSelectCoverImage => 'Please, select a cover image.';

  @override
  String get errorChooseTransport => 'Please, choose a transport type.';

  @override
  String get errorAddOneTraveler => 'Add at least one traveler to the trip.';

  @override
  String get errorMinTwoStops => 'The trip must have at least a departure point and a destination.';

  @override
  String get errorAllStopsNeedLocation => 'All destinations must have a location filled in.';

  @override
  String get errorAllStopsNeedDates => 'All arrival and departure dates for destinations must be filled in.';

  @override
  String get errorDepartureBeforeArrival => 'A destination\'s departure date cannot be earlier than its arrival date.';

  @override
  String get errorArrivalBeforePreviousDeparture => 'A destination\'s arrival cannot be before the departure from the previous location.';

  @override
  String get errorTravelerNameTooShort => 'The name must have at least 3 characters.';

  @override
  String get errorTravelerNameTooLong => 'The name cannot exceed 50 characters.';

  @override
  String get errorTravelerAgeInvalid => 'Please, enter a valid age (0-120).';

  @override
  String get unexpectedErrorOnSave => 'An unexpected error occurred while saving.';

  @override
  String get errorLoadingTravels => 'Error loading travels.';

  @override
  String get titleMinLengthError => 'Title must have at least 3 characters.';

  @override
  String get cropperToolbarTitle => 'Crop Image';

  @override
  String get noTravelerFound => 'No traveler found.';

  @override
  String get registerTraveler => 'Register Traveler';

  @override
  String get showMap => 'Show map';

  @override
  String get addDestination => 'Add destination';

  @override
  String get removeDestinationTooltip => 'Remove destination';

  @override
  String get titleMaxLengthError => 'Title cannot exceed 50 characters.';

  @override
  String get travelSavedSuccess => 'Travel saved successfully!';
}
