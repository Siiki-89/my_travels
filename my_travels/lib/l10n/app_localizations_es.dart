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

  @override
  String get noSearchResults => 'No se encontraron viajes con ese nombre.';

  @override
  String get ongoingTravels => 'Viajes en curso:';

  @override
  String get completedTravels => 'Viajes completados:';

  @override
  String get noOngoingTravels => 'No hay viajes en curso.';

  @override
  String get noCompletedTravels => 'No has completado ningún viaje.';

  @override
  String get clearFormTitle => 'Limpiar Formulario';

  @override
  String get clearFormContent => '¿Estás seguro de que te gustaría borrar todos los datos?';

  @override
  String get clearFormConfirm => 'Limpiar';

  @override
  String get errorCommentEmpty => 'Por favor, escribe algo.';

  @override
  String get errorCommentTooLong => 'El comentario no puede tener más de 280 caracteres.';

  @override
  String get errorSelectAuthor => 'Por favor, seleccione el autor del comentario.';

  @override
  String get errorLinkCommentToLocation => 'Por favor, vincule el comentario a un lugar del viaje.';

  @override
  String get errorSelectCoverImage => 'Por favor, selecciona una imagen de portada.';

  @override
  String get errorChooseTransport => 'Por favor, elige un tipo de transporte.';

  @override
  String get errorAddOneTraveler => 'Añade al menos un viajero al viaje.';

  @override
  String get errorMinTwoStops => 'El viaje debe tener al menos un punto de partida y un destino.';

  @override
  String get errorAllStopsNeedLocation => 'Todos los destinos deben tener una ubicación rellenada.';

  @override
  String get errorAllStopsNeedDates => 'Todas las fechas de llegada y salida de los destinos deben ser rellenadas.';

  @override
  String get errorDepartureBeforeArrival => 'La fecha de salida de un destino no puede ser anterior a su fecha de llegada.';

  @override
  String get errorArrivalBeforePreviousDeparture => 'La llegada a un destino no puede ser anterior a la salida del lugar previo.';

  @override
  String get errorTravelerNameTooShort => 'El nombre debe tener al menos 3 caracteres.';

  @override
  String get errorTravelerNameTooLong => 'El nombre no puede exceder los 50 caracteres.';

  @override
  String get errorTravelerAgeInvalid => 'Por favor, ingresa una edad válida (0-120).';

  @override
  String get unexpectedErrorOnSave => 'Ocurrió un error inesperado al guardar.';

  @override
  String get errorLoadingTravels => 'Error al cargar los viajes.';

  @override
  String get titleMinLengthError => 'El título debe tener al menos 3 caracteres.';

  @override
  String get cropperToolbarTitle => 'Recortar Imagen';

  @override
  String get noTravelerFound => 'No se encontró ningún viajero.';

  @override
  String get registerTraveler => 'Registrar Viajero';

  @override
  String get showMap => 'Mostrar mapa';

  @override
  String get addDestination => 'Añadir destino';

  @override
  String get removeDestinationTooltip => 'Eliminar destino';

  @override
  String get titleMaxLengthError => 'El título no puede exceder los 50 caracteres.';

  @override
  String get travelSavedSuccess => '¡Viaje guardado con éxito!';

  @override
  String get noRouteToShow => 'No hay ninguna ruta que mostrar.';

  @override
  String get languageNameEnglish => 'Inglés';

  @override
  String get languageNamePortuguese => 'Portugués';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get nameMinLengthError => 'El nombre debe contener 3 o más letras.';

  @override
  String get noTravelToShow => 'No hay ningún viaje que mostrar.';

  @override
  String get deleteTravelTitle => 'Eliminar Viaje';

  @override
  String deleteTravelContent(String travelTitle) {
    return '¿Está seguro de que desea eliminar permanentemente el viaje \"$travelTitle\"?';
  }

  @override
  String get participants => 'Participantes';

  @override
  String get travelRoute => 'Ruta del viaje';

  @override
  String comments(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
      zero: 'Ningún comentario',
    );
    return '$_temp0';
  }

  @override
  String get noCommentsYet => 'Aún no hay comentarios.';

  @override
  String get anonymous => 'Anónimo';

  @override
  String yearsOld(Object age) {
    return '$age años';
  }

  @override
  String get addComment => 'Añadir comentario';

  @override
  String get noImagesToShow => 'No hay imágenes para mostrar.';

  @override
  String get addImageCommentTitle => 'Añadir Nuevas Fotos';

  @override
  String get addImageCommentContent => 'Selecciona fotos de tu galería para añadir al viaje.';

  @override
  String get generalTrip => 'Viaje general';

  @override
  String get linkToLocation => 'Vincular a un lugar';

  @override
  String get generalTripOptional => 'General del viaje (opcional)';

  @override
  String travelNotFound(int travelId) {
    return 'Viaje con ID $travelId no encontrada.';
  }

  @override
  String get errorLoadingTravelDetails => 'Error al cargar los detalles del viaje.';

  @override
  String get errorSavingImages => 'Error al guardar las imágenes.';

  @override
  String get errorDeletingTravel => 'Error al eliminar el viaje.';

  @override
  String get errorUpdatingStatus => 'Error al actualizar el estado del viaje.';

  @override
  String get errorGeneratingPdf => 'Error al generar el PDF.';

  @override
  String get saveImagesNoTravelers => 'No se puede guardar: el viaje no tiene participantes.';

  @override
  String get saveImagesNoStartPoint => 'No se puede guardar: el viaje no tiene punto de partida.';

  @override
  String get travelMarkedAsCompleted => '¡Viaje marcado como completado!';

  @override
  String get travelReopened => 'Viaje reabierto.';

  @override
  String get errorSavingComment => 'Ocurrió un error inesperado al guardar el comentario.';

  @override
  String get newCommentAppBarTitle => 'Hacer un comentario';

  @override
  String travelFor(String title) {
    return 'Viaje a $title';
  }

  @override
  String get participant => 'Participante';

  @override
  String get selectAuthorHint => 'Selecciona el autor del comentario';

  @override
  String get travelLocation => 'Lugar del viaje';

  @override
  String get linkToLocationHint => 'Vincular a un lugar';

  @override
  String get comment => 'Comentario';

  @override
  String get selectPhotos => 'Seleccionar Fotos';

  @override
  String get destinationNotDefined => 'Destino no definido';

  @override
  String get travelParticipantsTitle => 'Participantes del Viaje';

  @override
  String get travelMapTitle => 'Mapa del Viaje';

  @override
  String get stopPointTitle => 'Punto de Parada';

  @override
  String get anonymousTraveler => 'Anónimo';

  @override
  String get transportation => 'Transporte';

  @override
  String get finalPageQuote1 => 'Un viaje no se mide en millas, sino en momentos.';

  @override
  String get finalPageQuote2 => 'Cada página de este folleto guarda más que paisajes: son sonrisas espontáneas, descubrimientos inesperados, conversaciones que llegaron al alma y silencios que hablaron más que las palabras.';
}
