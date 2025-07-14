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
}
