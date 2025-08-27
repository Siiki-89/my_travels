// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get language => 'Idioma';

  @override
  String get appName => 'Mis Viajes';

  @override
  String get users => 'Participantes';

  @override
  String get addTraveler => 'Añadir Participante';

  @override
  String get travelerNameHint => 'Nombre del Participante';

  @override
  String get ageHint => 'Edad';

  @override
  String get nameRequiredError => 'El nombre del participante es obligatorio.';

  @override
  String get ageRequiredError => 'Por favor, ingrese una edad válida.';

  @override
  String get travelerAddedSuccess => '¡Participante añadido con éxito!';

  @override
  String get travelerUpdatedSuccess => '¡Participante actualizado con éxito!';

  @override
  String get travelerDeletedSuccess => '¡Participante eliminado!';

  @override
  String get errorAddingTraveler => 'Error al añadir participante: ';

  @override
  String get errorUpdatingTraveler => 'Error al actualizar participante: ';

  @override
  String get errorDeletingTraveler => 'Error al eliminar participante: ';

  @override
  String get errorLoadingTravelers => 'Error al cargar participantes: ';

  @override
  String get noTravelersRegistered => 'Ningún participante registrado.';

  @override
  String get confirmDeletionTitle => 'Confirmar Eliminación';

  @override
  String confirmDeletionContent(String travelerName) {
    return '¿Está seguro de que desea eliminar a $travelerName?';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get editButton => 'Editar';

  @override
  String get clearButton => 'Borrar';

  @override
  String get settings => 'Configuración';

  @override
  String get darkModeTitle => 'Modo Oscuro';

  @override
  String get darkModeSubtitle => 'Activar o desactivar tema oscuro';

  @override
  String get home => 'Inicio';

  @override
  String get add => 'Agregar';

  @override
  String get travelAddTitle => 'Título del viaje';

  @override
  String get travelAddStartJourneyDateText => 'Inicio del viaje';

  @override
  String get travelAddStart => 'Inicio';

  @override
  String get travelAddFinal => 'Final';

  @override
  String get travelAddTypeLocomotion => 'Tipo de vehículo';

  @override
  String get vehicleAirplane => 'Avión';

  @override
  String get vehicleBus => 'Autobús';

  @override
  String get vehicleCar => 'Coche';

  @override
  String get vehicleCruise => 'Crucero';

  @override
  String get vehicleMotorcycle => 'Motocicleta';

  @override
  String get travelAddTrip => 'Ruta de viaje';

  @override
  String get travelAddStartintPoint => 'Elegir punto de partida...';

  @override
  String get travelAddFinalPoint => 'informar el destino ';

  @override
  String get travelAddDecriptionText => '¿Qué harás aquí?';

  @override
  String get travelAddPointButton => 'Guardar destino';

  @override
  String get travelAddTypeInterest => 'Puntos de interés del grupo';

  @override
  String get experienceTitle => 'Elige intereses';

  @override
  String get experiencePark => 'Parque';

  @override
  String get experienceBar => 'Bar';

  @override
  String get experienceCulinary => 'Gastronomía';

  @override
  String get experienceHistoric => 'Lugares históricos';

  @override
  String get experienceNature => 'Natureza';

  @override
  String get experienceCulture => 'Cultural';

  @override
  String get experienceShow => 'Espectáculo';

  @override
  String get travelerToTravelTitle => 'Elige viajeros';

  @override
  String get mapAppBarTitle => 'Ruta';

  @override
  String get noTravelersTitle => 'Tu catálogo del viajero';

  @override
  String get noTravelersSubtitle => 'Añade amigos y familiares aquí...';

  @override
  String get travelerManagementHint => 'Gestiona viajeros aquí. Puedes añadir fácilmente a tus futuros viajes a las personas guardadas.';

  @override
  String get confirmDeletion => 'Confirmar Eliminación';

  @override
  String get areYouSureYouWantToDelete => '¿Estás seguro de que deseas eliminar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get noTravelsTitle => 'No hay viajes registrados';

  @override
  String get noTravelsSubtitle => 'Comienza agregando un destino y crea tu catálogo de experiencias.';

  @override
  String get travelManagementHint => 'Administra todos tus viajes aquí. Quedarán guardados y podrás revisarlos o editarlos cuando quieras.';

  @override
  String get updateHint => 'actualizar';

  @override
  String get enterName => 'Por favor, ingrese un nombre.';

  @override
  String get enterValidNumber => 'Por favor, ingrese un número válido.';

  @override
  String get enterAge => 'Por favor, ingrese una edad.';

  @override
  String get homeSearchHint => 'buscar por título...';

  @override
  String get homeButtonExplore => 'Explorar';

  @override
  String get ageBelowZero => 'La edad debe ser mayor o igual a 0.';

  @override
  String get ageAboveNormal => 'Edad por encima de lo normal.';
}
