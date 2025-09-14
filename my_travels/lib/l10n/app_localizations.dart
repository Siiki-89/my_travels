import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'My Travels'**
  String get appName;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Travelers'**
  String get users;

  /// No description provided for @addTraveler.
  ///
  /// In en, this message translates to:
  /// **'Add Traveler'**
  String get addTraveler;

  /// No description provided for @travelerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Traveler Name'**
  String get travelerNameHint;

  /// No description provided for @ageHint.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageHint;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Traveler name is required.'**
  String get nameRequiredError;

  /// No description provided for @ageRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age.'**
  String get ageRequiredError;

  /// No description provided for @travelerAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Traveler added successfully!'**
  String get travelerAddedSuccess;

  /// No description provided for @travelerUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Traveler updated successfully!'**
  String get travelerUpdatedSuccess;

  /// No description provided for @travelerDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Traveler deleted!'**
  String get travelerDeletedSuccess;

  /// No description provided for @errorAddingTraveler.
  ///
  /// In en, this message translates to:
  /// **'Error adding traveler: '**
  String get errorAddingTraveler;

  /// No description provided for @errorUpdatingTraveler.
  ///
  /// In en, this message translates to:
  /// **'Error updating traveler: '**
  String get errorUpdatingTraveler;

  /// No description provided for @errorDeletingTraveler.
  ///
  /// In en, this message translates to:
  /// **'Error deleting traveler: '**
  String get errorDeletingTraveler;

  /// No description provided for @errorLoadingTravelers.
  ///
  /// In en, this message translates to:
  /// **'Error loading travelers: '**
  String get errorLoadingTravelers;

  /// No description provided for @noTravelersRegistered.
  ///
  /// In en, this message translates to:
  /// **'No travelers registered.'**
  String get noTravelersRegistered;

  /// No description provided for @confirmDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletionTitle;

  /// No description provided for @confirmDeletionContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {travelerName}?'**
  String confirmDeletionContent(String travelerName);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Activate or deactivate dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @travelAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip title'**
  String get travelAddTitle;

  /// No description provided for @travelAddStartJourneyDateText.
  ///
  /// In en, this message translates to:
  /// **'Start of the journey'**
  String get travelAddStartJourneyDateText;

  /// No description provided for @travelAddStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get travelAddStart;

  /// No description provided for @travelAddFinal.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get travelAddFinal;

  /// No description provided for @travelAddTypeLocomotion.
  ///
  /// In en, this message translates to:
  /// **'Type of vehicle'**
  String get travelAddTypeLocomotion;

  /// No description provided for @vehicleAirplane.
  ///
  /// In en, this message translates to:
  /// **'Airplane'**
  String get vehicleAirplane;

  /// No description provided for @vehicleBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get vehicleBus;

  /// No description provided for @vehicleCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicleCar;

  /// No description provided for @vehicleCruise.
  ///
  /// In en, this message translates to:
  /// **'Cruise'**
  String get vehicleCruise;

  /// No description provided for @vehicleMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get vehicleMotorcycle;

  /// No description provided for @travelAddTrip.
  ///
  /// In en, this message translates to:
  /// **'Travel route'**
  String get travelAddTrip;

  /// No description provided for @travelAddStartintPoint.
  ///
  /// In en, this message translates to:
  /// **'Choose starting point...'**
  String get travelAddStartintPoint;

  /// No description provided for @travelAddFinalPoint.
  ///
  /// In en, this message translates to:
  /// **'Inform the destination '**
  String get travelAddFinalPoint;

  /// No description provided for @travelAddDecriptionText.
  ///
  /// In en, this message translates to:
  /// **'What will you do here?'**
  String get travelAddDecriptionText;

  /// No description provided for @travelAddPointButton.
  ///
  /// In en, this message translates to:
  /// **'Save destination'**
  String get travelAddPointButton;

  /// No description provided for @travelAddTypeInterest.
  ///
  /// In en, this message translates to:
  /// **'Group\'s points of interest'**
  String get travelAddTypeInterest;

  /// No description provided for @experienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose interests'**
  String get experienceTitle;

  /// No description provided for @experiencePark.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get experiencePark;

  /// No description provided for @experienceBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get experienceBar;

  /// No description provided for @experienceCulinary.
  ///
  /// In en, this message translates to:
  /// **'Culinary'**
  String get experienceCulinary;

  /// No description provided for @experienceHistoric.
  ///
  /// In en, this message translates to:
  /// **'Historic Place'**
  String get experienceHistoric;

  /// No description provided for @experienceNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get experienceNature;

  /// No description provided for @experienceCulture.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get experienceCulture;

  /// No description provided for @experienceShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get experienceShow;

  /// No description provided for @travelerToTravelTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose travels'**
  String get travelerToTravelTitle;

  /// No description provided for @mapAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get mapAppBarTitle;

  /// No description provided for @noTravelersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Traveler\'s Catalog'**
  String get noTravelersTitle;

  /// No description provided for @noTravelersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add friends and family here...'**
  String get noTravelersSubtitle;

  /// No description provided for @travelerManagementHint.
  ///
  /// In en, this message translates to:
  /// **'Manage travelers here. Saved people can be easily added to your future trips.'**
  String get travelerManagementHint;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @areYouSureYouWantToDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSureYouWantToDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noTravelsTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips recorded'**
  String get noTravelsTitle;

  /// No description provided for @noTravelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a destination and build your travel catalog.'**
  String get noTravelsSubtitle;

  /// No description provided for @travelManagementHint.
  ///
  /// In en, this message translates to:
  /// **'Manage all your trips here. They will be saved and can be viewed or edited anytime.'**
  String get travelManagementHint;

  /// No description provided for @updateHint.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateHint;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get enterName;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get enterValidNumber;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter an age.'**
  String get enterAge;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title...'**
  String get homeSearchHint;

  /// No description provided for @homeButtonExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeButtonExplore;

  /// No description provided for @ageBelowZero.
  ///
  /// In en, this message translates to:
  /// **'Age must be greater than or equal to 0.'**
  String get ageBelowZero;

  /// No description provided for @ageAboveNormal.
  ///
  /// In en, this message translates to:
  /// **'Age above normal.'**
  String get ageAboveNormal;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No trips found with that name.'**
  String get noSearchResults;

  /// No description provided for @ongoingTravels.
  ///
  /// In en, this message translates to:
  /// **'Ongoing travels:'**
  String get ongoingTravels;

  /// No description provided for @completedTravels.
  ///
  /// In en, this message translates to:
  /// **'Completed travels:'**
  String get completedTravels;

  /// No description provided for @noOngoingTravels.
  ///
  /// In en, this message translates to:
  /// **'No ongoing travels.'**
  String get noOngoingTravels;

  /// No description provided for @noCompletedTravels.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t completed any travels yet.'**
  String get noCompletedTravels;

  /// No description provided for @clearFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Form'**
  String get clearFormTitle;

  /// No description provided for @clearFormContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you would like to clear all the data?'**
  String get clearFormContent;

  /// No description provided for @clearFormConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFormConfirm;

  /// No description provided for @errorCommentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please, type something.'**
  String get errorCommentEmpty;

  /// No description provided for @errorCommentTooLong.
  ///
  /// In en, this message translates to:
  /// **'The comment cannot be longer than 280 characters.'**
  String get errorCommentTooLong;

  /// No description provided for @errorSelectAuthor.
  ///
  /// In en, this message translates to:
  /// **'Please, select the author of the comment.'**
  String get errorSelectAuthor;

  /// No description provided for @errorLinkCommentToLocation.
  ///
  /// In en, this message translates to:
  /// **'Please, link the comment to a location on the trip.'**
  String get errorLinkCommentToLocation;

  /// No description provided for @errorSelectCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Please, select a cover image.'**
  String get errorSelectCoverImage;

  /// No description provided for @errorChooseTransport.
  ///
  /// In en, this message translates to:
  /// **'Please, choose a transport type.'**
  String get errorChooseTransport;

  /// No description provided for @errorAddOneTraveler.
  ///
  /// In en, this message translates to:
  /// **'Add at least one traveler to the trip.'**
  String get errorAddOneTraveler;

  /// No description provided for @errorMinTwoStops.
  ///
  /// In en, this message translates to:
  /// **'The trip must have at least a departure point and a destination.'**
  String get errorMinTwoStops;

  /// No description provided for @errorAllStopsNeedLocation.
  ///
  /// In en, this message translates to:
  /// **'All destinations must have a location filled in.'**
  String get errorAllStopsNeedLocation;

  /// No description provided for @errorAllStopsNeedDates.
  ///
  /// In en, this message translates to:
  /// **'All arrival and departure dates for destinations must be filled in.'**
  String get errorAllStopsNeedDates;

  /// No description provided for @errorDepartureBeforeArrival.
  ///
  /// In en, this message translates to:
  /// **'A destination\'s departure date cannot be earlier than its arrival date.'**
  String get errorDepartureBeforeArrival;

  /// No description provided for @errorArrivalBeforePreviousDeparture.
  ///
  /// In en, this message translates to:
  /// **'A destination\'s arrival cannot be before the departure from the previous location.'**
  String get errorArrivalBeforePreviousDeparture;

  /// No description provided for @errorTravelerNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'The name must have at least 3 characters.'**
  String get errorTravelerNameTooShort;

  /// No description provided for @errorTravelerNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'The name cannot exceed 50 characters.'**
  String get errorTravelerNameTooLong;

  /// No description provided for @errorTravelerAgeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please, enter a valid age (0-120).'**
  String get errorTravelerAgeInvalid;

  /// No description provided for @unexpectedErrorOnSave.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while saving.'**
  String get unexpectedErrorOnSave;

  /// No description provided for @errorLoadingTravels.
  ///
  /// In en, this message translates to:
  /// **'Error loading travels.'**
  String get errorLoadingTravels;

  /// No description provided for @titleMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Title must have at least 3 characters.'**
  String get titleMinLengthError;

  /// No description provided for @cropperToolbarTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropperToolbarTitle;

  /// No description provided for @noTravelerFound.
  ///
  /// In en, this message translates to:
  /// **'No traveler found.'**
  String get noTravelerFound;

  /// No description provided for @registerTraveler.
  ///
  /// In en, this message translates to:
  /// **'Register Traveler'**
  String get registerTraveler;

  /// No description provided for @showMap.
  ///
  /// In en, this message translates to:
  /// **'Show map'**
  String get showMap;

  /// No description provided for @addDestination.
  ///
  /// In en, this message translates to:
  /// **'Add destination'**
  String get addDestination;

  /// No description provided for @removeDestinationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove destination'**
  String get removeDestinationTooltip;

  /// No description provided for @titleMaxLengthError.
  ///
  /// In en, this message translates to:
  /// **'Title cannot exceed 50 characters.'**
  String get titleMaxLengthError;

  /// No description provided for @travelSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Travel saved successfully!'**
  String get travelSavedSuccess;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
