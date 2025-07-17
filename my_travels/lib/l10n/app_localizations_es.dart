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
  String get travelAddStart => 'Inicio';

  @override
  String get travelAddFinal => 'Final';

  @override
  String get travelAddTypeLocomotion => 'Tipo de vehículo';

  @override
  String get travelAddTypeCar => 'Auto';

  @override
  String get travelAddTypeMotorcycle => 'Moto';

  @override
  String get travelAddTypeBuss => 'Autobús';

  @override
  String get travelAddTypePlane => 'Avión';

  @override
  String get travelAddTypeCruise => 'Crucero';

  @override
  String get travelAddStartintPoint => 'Elegir punto de partida...';

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
}
