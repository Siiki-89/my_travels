// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get language => 'Idioma';

  @override
  String get appName => 'Minhas Viagens';

  @override
  String get users => 'Participantes';

  @override
  String get addTraveler => 'Adicionar Participante';

  @override
  String get travelerNameHint => 'Nome do Participante';

  @override
  String get ageHint => 'Idade';

  @override
  String get nameRequiredError => 'O nome do participante é obrigatório.';

  @override
  String get ageRequiredError => 'Por favor, insira uma idade válida.';

  @override
  String get travelerAddedSuccess => 'Participante adicionado com sucesso!';

  @override
  String get travelerUpdatedSuccess => 'Participante atualizado com sucesso!';

  @override
  String get travelerDeletedSuccess => 'Participante excluído!';

  @override
  String get errorAddingTraveler => 'Erro ao adicionar participante: ';

  @override
  String get errorUpdatingTraveler => 'Erro ao atualizar participante: ';

  @override
  String get errorDeletingTraveler => 'Erro ao excluir participante: ';

  @override
  String get errorLoadingTravelers => 'Erro ao carregar participantes: ';

  @override
  String get noTravelersRegistered => 'Nenhum participante cadastrado.';

  @override
  String get confirmDeletionTitle => 'Confirmar Exclusão';

  @override
  String confirmDeletionContent(String travelerName) {
    return 'Tem certeza que deseja excluir $travelerName?';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Excluir';

  @override
  String get saveButton => 'Salvar';

  @override
  String get editButton => 'Editar';

  @override
  String get clearButton => 'Limpar';

  @override
  String get settings => 'Configurações';

  @override
  String get darkModeTitle => 'Modo Escuro';

  @override
  String get darkModeSubtitle => 'Ativar ou desativar o tema escuro';

  @override
  String get home => 'Início';

  @override
  String get add => 'Adicionar';

  @override
  String get travelAddTitle => 'Título da viagem';

  @override
  String get travelAddStartJourneyDateText => 'Inicio da viagem';

  @override
  String get travelAddStart => 'Início';

  @override
  String get travelAddFinal => 'Final';

  @override
  String get travelAddTypeLocomotion => 'Tipo de veiculo';

  @override
  String get vehicleAirplane => 'Avião';

  @override
  String get vehicleBus => 'Ônibus';

  @override
  String get vehicleCar => 'Carro';

  @override
  String get vehicleCruise => 'Cruzeiro';

  @override
  String get vehicleMotorcycle => 'Moto';

  @override
  String get travelAddTrip => 'Trajeto da viagem';

  @override
  String get travelAddStartintPoint => 'Escolha ponto de partida...';

  @override
  String get travelAddFinalPoint => 'Informe o destino ';

  @override
  String get travelAddDecriptionText => 'O que fará aqui?';

  @override
  String get travelAddPointButton => 'Salvar destino';

  @override
  String get travelAddTypeInterest => 'Pontos de interesse do grupo';

  @override
  String get experienceTitle => 'Escolha os interesses';

  @override
  String get experiencePark => 'Parque';

  @override
  String get experienceBar => 'Bar';

  @override
  String get experienceCulinary => 'Culinaria';

  @override
  String get experienceHistoric => 'Lugares Historicos';

  @override
  String get experienceNature => 'Natureza';

  @override
  String get experienceCulture => 'Cultural';

  @override
  String get experienceShow => 'Show';

  @override
  String get travelerToTravelTitle => 'Escolha os viajantes';

  @override
  String get mapAppBarTitle => 'Percurso';

  @override
  String get noTravelersTitle => 'Seu Catálogo de Viajantes';

  @override
  String get noTravelersSubtitle => 'Adicione amigos e familiares aqui...';

  @override
  String get travelerManagementHint => 'Faça o gerenciamento dos viajantes aqui. As pessoas salvas podem ser facilmente adicionadas às suas viagens futuras.';

  @override
  String get confirmDeletion => 'Confirmar Exclusão';

  @override
  String get areYouSureYouWantToDelete => 'Tem certeza que deseja excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Deletar';

  @override
  String get noTravelsTitle => 'Nenhuma viagem registrada';

  @override
  String get noTravelsSubtitle => 'Comece adicionando um destino e monte seu catálogo de experiências.';

  @override
  String get travelManagementHint => 'Gerencie todas as suas viagens aqui. Elas ficarão salvas e poderão ser consultadas ou editadas sempre que precisar.';

  @override
  String get updateHint => 'Atualizar';

  @override
  String get enterName => 'Por favor, insira um nome.';

  @override
  String get enterValidNumber => 'Por favor, insira um número válido.';

  @override
  String get enterAge => 'Por favor, insira uma idade.';

  @override
  String get homeSearchHint => 'Buscar por título...';

  @override
  String get homeButtonExplore => 'Explorar';

  @override
  String get ageBelowZero => 'Idade deve ser maior ou igual a 0.';

  @override
  String get ageAboveNormal => 'Idade acima do normal.';

  @override
  String get noSearchResults => 'Nenhuma viagem encontrada com esse nome.';

  @override
  String get ongoingTravels => 'Viagens em andamento:';

  @override
  String get completedTravels => 'Viagens concluidas:';

  @override
  String get noOngoingTravels => 'Nenhuma viagem em andamento.';

  @override
  String get noCompletedTravels => 'Não completou nenhuma viagem.';

  @override
  String get clearFormTitle => 'Limpar Formulário';

  @override
  String get clearFormContent => 'Você tem certeza que gostaria de limpar todos os dados?';

  @override
  String get clearFormConfirm => 'Limpar';

  @override
  String get errorCommentEmpty => 'Por favor, digite algo.';

  @override
  String get errorCommentTooLong => 'O comentário não pode ter mais de 280 caracteres.';

  @override
  String get errorSelectAuthor => 'Por favor, selecione o autor do comentário.';

  @override
  String get errorLinkCommentToLocation => 'Por favor, vincule o comentário a um local da viagem.';

  @override
  String get errorSelectCoverImage => 'Por favor, selecione uma imagem de capa.';

  @override
  String get errorChooseTransport => 'Por favor, escolha um tipo de transporte.';

  @override
  String get errorAddOneTraveler => 'Adicione pelo menos um viajante à viagem.';

  @override
  String get errorMinTwoStops => 'A viagem deve ter pelo menos um ponto de partida e um destino.';

  @override
  String get errorAllStopsNeedLocation => 'Todos os destinos devem ter um local preenchido.';

  @override
  String get errorAllStopsNeedDates => 'Todas as datas de chegada e partida dos destinos devem ser preenchidas.';

  @override
  String get errorDepartureBeforeArrival => 'A data de partida de um destino não pode ser anterior à data de chegada.';

  @override
  String get errorArrivalBeforePreviousDeparture => 'A chegada em um destino não pode ser antes da partida do local anterior.';

  @override
  String get errorTravelerNameTooShort => 'O nome deve ter pelo menos 3 caracteres.';

  @override
  String get errorTravelerNameTooLong => 'O nome não pode exceder 50 caracteres.';

  @override
  String get errorTravelerAgeInvalid => 'Por favor, insira uma idade válida (0-120).';

  @override
  String get unexpectedErrorOnSave => 'Ocorreu um erro inesperado ao salvar.';

  @override
  String get errorLoadingTravels => 'Erro ao carregar viagens.';

  @override
  String get titleMinLengthError => 'O título deve ter pelo menos 3 caracteres.';

  @override
  String get cropperToolbarTitle => 'Recortar Imagem';

  @override
  String get noTravelerFound => 'Nenhum viajante encontrado.';

  @override
  String get registerTraveler => 'Cadastrar Viajante';

  @override
  String get showMap => 'Mostrar mapa';

  @override
  String get addDestination => 'Adicionar destino';

  @override
  String get removeDestinationTooltip => 'Remover destino';

  @override
  String get titleMaxLengthError => 'O título não pode exceder 50 caracteres.';

  @override
  String get travelSavedSuccess => 'Viagem salva com sucesso!';
}
