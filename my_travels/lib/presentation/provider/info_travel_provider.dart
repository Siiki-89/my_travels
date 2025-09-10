import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/model/transport_model.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/utils/transport_data.dart';
import 'package:provider/provider.dart';

class InfoTravelProvider extends ChangeNotifier {
  final TravelRepository _travelRepository;
  final CommentRepository _commentRepository;

  // Construtor com Injeção de Dependência (melhor prática)
  InfoTravelProvider({
    required TravelRepository travelRepository,
    required CommentRepository commentRepository,
  }) : _travelRepository = travelRepository,
       _commentRepository = commentRepository;

  // --- ESTADO DA UI ---
  Travel? _travel;
  TransportModel? _vehicleModel;
  List<Comment> _comments = [];
  List<String> _allImagePaths = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentImageIndex = 0;

  // --- VARIÁVEIS DE CONTROLE INTERNO ---
  int? _currentlyLoadedId; // Guarda o ID da viagem que já foi carregada
  bool _isFetching = false; // Guarda se uma busca já está em andamento

  // --- GETTERS ---
  Travel? get travel => _travel;
  TransportModel? get vehicleModel => _vehicleModel;
  List<Comment> get comments => _comments;
  List<String> get allImagePaths => _allImagePaths;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentImageIndex => _currentImageIndex;

  /// Este é o método "porteiro". A UI deve SEMPRE chamar este.
  /// É seguro chamá-lo em cada build.
  void fetchTravelDetailsIfNeeded(BuildContext context, int? travelId) {
    // A verificação agora é robusta. Não faz nada se:
    // 1. O ID for nulo.
    // 2. Uma busca já estiver em andamento.
    // 3. Os dados para este ID já foram carregados com sucesso.
    if (travelId == null || _isFetching || _currentlyLoadedId == travelId) {
      return;
    }

    // Se passar pela verificação, inicia a busca real.
    _fetchTravelDetails(context, travelId);
  }

  /// Este é o método "trabalhador". Contém a lógica de busca real.
  Future<void> _fetchTravelDetails(BuildContext context, int? travelId) async {
    _isFetching = true;
    _isLoading = true;
    _travel =
        null; // Limpa os dados antigos para não mostrar info da viagem anterior
    notifyListeners(); // Agora esta chamada é segura

    try {
      final fetchedTravel = await _travelRepository.getTravelById(travelId!);
      if (fetchedTravel == null) {
        throw Exception('Viagem com ID $travelId não foi encontrada.');
      }
      _travel = fetchedTravel;
      _currentlyLoadedId =
          travelId; // Marca este ID como carregado com sucesso.

      if (_travel?.vehicle != null && context.mounted) {
        final availableVehicles = getAvailableVehicles(context);
        _vehicleModel = availableVehicles.firstWhere(
          (model) => model.label == _travel!.vehicle,
          orElse: () => TransportModel(label: '', lottieAsset: ''),
        );
      }

      await _loadCommentsAndImages();

      if (context.mounted) {
        final mapProvider = context.read<MapProvider>();
        final stops = _travel!.stopPoints
            .where((s) => s.latitude != null && s.longitude != null)
            .map(
              (s) => LocationMapModel(
                locationId: s.id?.toString() ?? s.locationName,
                description: s.locationName,
                lat: s.latitude!,
                long: s.longitude!,
              ),
            )
            .toList();
        await mapProvider.createRouteFromStops(stops);
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar detalhes da viagem: $e';
      _currentlyLoadedId =
          null; // Reseta em caso de erro para permitir nova tentativa
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCommentsAndImages() async {
    if (_travel == null) return;
    final allComments = <Comment>[];
    for (final stopPoint in _travel!.stopPoints) {
      if (stopPoint.id != null) {
        final stopPointComments = await _commentRepository
            .getCommentsByStopPointId(stopPoint.id!);
        allComments.addAll(stopPointComments);
      }
    }
    _comments = allComments;

    final paths = <String>[];
    if (_travel!.coverImagePath != null &&
        _travel!.coverImagePath!.isNotEmpty) {
      paths.add(_travel!.coverImagePath!);
    }
    for (final comment in _comments) {
      paths.addAll(comment.photos.map((photo) => photo.imagePath));
    }
    _allImagePaths = paths;
  }

  void setCurrentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }
}
