import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart' as entity;
import 'package:my_travels/data/entities/travel_entity.dart' as entity;
import 'package:my_travels/data/entities/traveler_entity.dart' as entity;
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/domain/use_cases/save_travel_use_case.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/destination_model.dart';
import 'package:my_travels/model/experience_model.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/model/transport_model.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:provider/provider.dart';

/// [CreateTravelProvider] - Gerenciador de Estado para a Criação de Viagens.
///
/// Responsável por gerenciar o estado da tela de criação de viagem,
/// servindo como uma ponte entre a UI (View) e a lógica de negócio (Use Cases).
class CreateTravelProvider with ChangeNotifier {
  // ===========================================================================
  // SEÇÃO: DEPENDÊNCIAS E CAMADA DE DOMÍNIO
  // ===========================================================================

  final TravelRepository _travelRepository = TravelRepository();
  late final SaveTravelUseCase _saveTravelUseCase;

  /// Construtor: Inicializa o UseCase, injetando o repositório.
  CreateTravelProvider() {
    _saveTravelUseCase = SaveTravelUseCase(_travelRepository);
  }

  // ===========================================================================
  // SEÇÃO: ESTADO INTERNO DO PROVIDER (STATE)
  // ===========================================================================

  // -- Controladores de Texto --
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  // -- Estado do Formulário Principal --
  DateTime _startData = DateTime.now();
  DateTime _finalData = DateTime.now();
  File? _coverImage;
  TransportModel _transportSelect = TransportModel(label: '', lottieAsset: '');

  // -- Listas de Seleção e Dados --
  final List<ExperienceModel> _selectedExperiences = [];
  final List<ExperienceModel> _availableExperiences = [];
  final List<TransportModel> _availableTransport = [];
  List<DestinationModel> _destinations = [DestinationModel(id: 0)];

  // -- Controle de Edição de Destinos --
  int _nextId = 1;
  int? _editingIndex;
  DateTime? _tempArrivalDate;
  DateTime? _tempDepartureDate;
  final Map<int, bool> _destinationFirstTap = {};

  // -- Flags de Validação para a UI --
  bool validateImage = false;
  bool validateVehicle = false;
  bool validateTravelers = false;
  bool validateRoute = false;

  // ++ CORREÇÃO APLICADA ++
  // Flags para evitar carregamento múltiplo de dados estáticos.
  bool _experiencesLoaded = false;
  bool _vehiclesLoaded = false;

  // ===========================================================================
  // SEÇÃO: GETTERS (EXPOSIÇÃO SEGURA DO ESTADO PARA A UI)
  // ===========================================================================

  DateTime get startData => _startData;
  DateTime get finalData => _finalData;
  String get startDateString => formatDate(_startData);
  String get finalDateString => formatDate(_finalData);
  File? get coverImage => _coverImage;
  List<ExperienceModel> get selectedExperiences => _selectedExperiences;
  List<ExperienceModel> get availableExperiences => _availableExperiences;
  TransportModel get transportSelect => _transportSelect;
  List<TransportModel> get availableTransport => _availableTransport;
  List<DestinationModel> get destinations => _destinations;
  int? get editingIndex => _editingIndex;
  DateTime? get tempArrivalDate => _tempArrivalDate;
  DateTime? get tempDepartureDate => _tempDepartureDate;
  String get arrivalDateString =>
      _tempArrivalDate != null ? formatDate(_tempArrivalDate!) : 'Selecione';
  String get departureDateString => _tempDepartureDate != null
      ? formatDate(_tempDepartureDate!)
      : 'Selecione';

  // ===========================================================================
  // SEÇÃO: AÇÕES (MÉTODOS QUE MODIFICAM O ESTADO)
  // ===========================================================================

  /// Atualiza a imagem de capa da viagem.
  void setImage(File? newImage) {
    _coverImage = newImage;
    notifyListeners();
  }

  /// Atualiza as datas de início ou fim da viagem.
  void updateDate(DateTime newDate, bool isStartDate) {
    if (isStartDate) {
      _startData = newDate;
      if (_finalData.isBefore(_startData)) {
        _finalData = _startData;
      }
    } else {
      _finalData = newDate;
    }
    notifyListeners();
  }

  /// Formata uma data para o padrão dd/MM/yyyy.
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Carrega a lista de experiências disponíveis (apenas uma vez).
  void loadAvailableExperiences(BuildContext context) {
    // ++ CORREÇÃO APLICADA ++
    // Verifica o flag antes de carregar, para evitar múltiplas execuções.
    if (_experiencesLoaded) return;

    final appLocalizations = AppLocalizations.of(context)!;
    _availableExperiences.clear();
    _availableExperiences.addAll([
      ExperienceModel(
        label: appLocalizations.experiencePark,
        image: 'assets/images/experience/park.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceBar,
        image: 'assets/images/experience/bar.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceCulinary,
        image: 'assets/images/experience/culinary.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceHistoric,
        image: 'assets/images/experience/historic.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceNature,
        image: 'assets/images/experience/nature.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceCulture,
        image: 'assets/images/experience/culture.png',
      ),
      ExperienceModel(
        label: appLocalizations.experienceShow,
        image: 'assets/images/experience/show.png',
      ),
    ]);
    // ++ CORREÇÃO APLICADA ++
    // Atualiza o flag para indicar que os dados já foram carregados.
    _experiencesLoaded = true;
  }

  /// Verifica se uma experiência específica está na lista de selecionadas.
  bool isSelectedExperience(ExperienceModel experience) {
    return _selectedExperiences.contains(experience);
  }

  /// Adiciona ou remove uma experiência da lista de selecionadas.
  void toggleExperience(ExperienceModel experience) {
    if (isSelectedExperience(experience)) {
      _selectedExperiences.remove(experience);
    } else {
      _selectedExperiences.add(experience);
    }
    notifyListeners();
  }

  /// Verifica se um veículo específico é o selecionado.
  bool isSelectedVehicle(TransportModel transport) =>
      _transportSelect.label == transport.label;

  /// Define o veículo selecionado para a viagem.
  void selectVehicle(TransportModel transport) {
    _transportSelect = transport;
    notifyListeners();
  }

  /// Carrega a lista de veículos disponíveis (apenas uma vez).
  void loadAvailableVehicles(BuildContext context) {
    // ++ CORREÇÃO APLICADA ++
    // Verifica o flag antes de carregar, para evitar múltiplas execuções.
    if (_vehiclesLoaded) return;

    final appLocalizations = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _availableTransport.clear();
    const String lottiePath = 'assets/images/lottie/typelocomotion/';
    _availableTransport.addAll([
      TransportModel(
        label: appLocalizations.vehicleCar,
        lottieAsset: isDarkMode
            ? '${lottiePath}car_dark.json'
            : '${lottiePath}car.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleMotorcycle,
        lottieAsset: '${lottiePath}motorcycle.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleBus,
        lottieAsset: '${lottiePath}bus.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleAirplane,
        lottieAsset: '${lottiePath}airplane.json',
      ),
      TransportModel(
        label: appLocalizations.vehicleCruise,
        lottieAsset: isDarkMode
            ? '${lottiePath}cruise_dark.json'
            : '${lottiePath}cruise.json',
      ),
    ]);
    // ++ CORREÇÃO APLICADA ++
    // Atualiza o flag para indicar que os dados já foram carregados.
    _vehiclesLoaded = true;
  }

  /// Inicia o modo de edição para um destino específico.
  void startEditing(int index) {
    _editingIndex = index;
    final destination = _destinations[index];
    descriptionController.text = destination.description ?? '';
    if (destination.arrivalDate != null) {
      _tempArrivalDate = destination.arrivalDate;
      _tempDepartureDate = destination.departureDate;
    } else {
      if (index > 0) {
        final previousDepartureDate = _destinations[index - 1].departureDate;
        _tempArrivalDate = previousDepartureDate;
        _tempDepartureDate = previousDepartureDate?.add(
          const Duration(days: 1),
        );
      } else {
        _tempArrivalDate = _startData;
        _tempDepartureDate = _startData.add(const Duration(days: 1));
      }
    }
    notifyListeners();
  }

  /// Salva as alterações de um destino e finaliza o modo de edição.
  void concludeEditing() {
    if (_editingIndex != null) {
      final destination = _destinations[_editingIndex!];
      _destinations[_editingIndex!] = destination.copyWith(
        description: descriptionController.text,
        arrivalDate: _tempArrivalDate,
        departureDate: _tempDepartureDate,
      );
      _editingIndex = null;
      descriptionController.clear();
      _tempArrivalDate = null;
      _tempDepartureDate = null;
      notifyListeners();
    }
  }

  /// Adiciona um novo destino à lista.
  void addDestination() {
    _destinations.add(DestinationModel(id: _nextId++));
    notifyListeners();
  }

  /// Atualiza a localização de um destino que está sendo editado.
  void updateDestinationLocation(int index, LocationMapModel location) {
    if (index >= 0 && index < _destinations.length) {
      final destination = _destinations[index];
      _destinations[index] = destination.copyWith(
        location: location,
        description: location.description,
      );
      notifyListeners();
    }
  }

  /// Atualiza a data de chegada temporária durante a edição.
  void updateArrivalDate(DateTime date) {
    _tempArrivalDate = date;
    notifyListeners();
  }

  /// Atualiza a data de partida temporária durante a edição.
  void updateDepartureDate(DateTime date) {
    _tempDepartureDate = date;
    notifyListeners();
  }

  /// Remove um destino da lista pelo seu ID.
  void removeDestinationById(int id) {
    _destinations.removeWhere((dest) => dest.id == id);
    notifyListeners();
  }

  /// Orquestra a validação e o salvamento da viagem.
  Future<void> saveTravel(
    BuildContext context,
    TravelerProvider travelerProvider,
  ) async {
    _resetValidationFlags();
    concludeEditing();

    // 1. Monta a entidade 'Travel' com os dados do estado atual do provider.
    final travelToSave = entity.Travel(
      title: titleController.text,
      startDate: _startData,
      endDate: _finalData,
      vehicle: _transportSelect.label,
      coverImagePath: _coverImage?.path,
      stopPoints: _destinations
          .where((d) => d.location != null)
          .map(
            (destinationModel) => entity.StopPoint(
              travelId: 0,
              stopOrder: _destinations.indexOf(destinationModel),
              locationName: destinationModel.location!.description,
              latitude: destinationModel.location!.lat,
              longitude: destinationModel.location!.long,
              description: destinationModel.description,
              arrivalDate: destinationModel.arrivalDate,
              departureDate: destinationModel.departureDate,
            ),
          )
          .toList(),
      travelers: travelerProvider.selectedTravelers
          .map(
            (travelerModel) =>
                entity.Traveler(id: travelerModel.id, name: travelerModel.name),
          )
          .toList(),
      isFinished: false,
    );

    try {
      // 2. Chama o Use Case para executar a lógica de negócio (validação e salvamento).
      await _saveTravelUseCase.call(travelToSave);

      // 3. Em caso de SUCESSO, atualiza a home, mostra feedback e reseta o form.
      await context.read<HomeProvider>().fetchTravels();
      _showSuccessSnackBar(context, 'Viagem salva com sucesso!');
      resetTravelForm(travelerProvider);
    } on TravelValidationException catch (e) {
      // 4. Em caso de ERRO DE VALIDAÇÃO, mostra o erro e atualiza os flags da UI.
      _showErrorSnackBar(context, e.message);

      if (e is InvalidCoverImageException) validateImage = true;
      if (e is InvalidTransportException) validateVehicle = true;
      if (e is InvalidTravelersException) validateTravelers = true;
      if (e is InvalidRouteException) validateRoute = true;

      notifyListeners();
    } catch (e) {
      // 5. Em caso de outros erros, mostra uma mensagem genérica.
      _showErrorSnackBar(context, 'Ocorreu um erro inesperado ao salvar.');
      print("Erro genérico ao salvar a viagem: $e");
    }
  }

  /// Registra o primeiro toque em um destino.
  bool hasTappedOnce(int index) => _destinationFirstTap[index] ?? false;
  void registerFirstTap(int index) {
    _destinationFirstTap[index] = true;
    notifyListeners();
  }

  /// Reseta o estado de "primeiro toque" para um destino.
  void resetFirstTap(int index) {
    _destinationFirstTap.remove(index);
    notifyListeners();
  }

  /// Limpa o estado de "primeiro toque" para todos os destinos.
  void resetAllTaps() {
    _destinationFirstTap.clear();
    notifyListeners();
  }

  /// Reseta todos os flags de validação para o estado inicial.
  _resetValidationFlags() {
    validateImage = false;
    validateVehicle = false;
    validateTravelers = false;
    validateRoute = false;
    notifyListeners();
  }

  /// Limpa e reseta completamente o estado do formulário.
  /// Limpa e reseta completamente o estado do formulário.
  void resetTravelForm(TravelerProvider travelerProvider) {
    // Acessamos a lista pública do TravelerProvider e usamos o método .clear()
    travelerProvider.selectedTravelers.clear();

    titleController.clear();
    descriptionController.clear();
    _coverImage = null;
    _startData = DateTime.now();
    _finalData = DateTime.now();
    _selectedExperiences.clear();
    _transportSelect = TransportModel(label: '', lottieAsset: '');
    _destinations = [DestinationModel(id: 0)];
    _nextId = 1;
    _editingIndex = null;
    _resetValidationFlags();
    _vehiclesLoaded = false;
    _experiencesLoaded = false;
    notifyListeners();
  }

  /// Exibe um SnackBar de erro.
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Exibe um SnackBar de sucesso (criado para consistência).
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
