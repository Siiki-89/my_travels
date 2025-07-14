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
}
