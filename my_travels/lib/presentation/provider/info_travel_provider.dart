import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:provider/provider.dart';

class InfoTravelProvider extends ChangeNotifier {
  final TravelRepository _travelRepository = TravelRepository();
  final CommentRepository _commentRepository = CommentRepository();

  Travel? _travel;
  Travel? get travel => _travel;

  // ... (resto das variáveis do provider)
  List<Comment> _comments = [];
  List<Comment> get comments => _comments;
  List<String> _allImagePaths = [];
  List<String> get allImagePaths => _allImagePaths;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  void setCurrentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  // >> MÉTODO ATUALIZADO <<
  Future<void> fetchTravelDetails(BuildContext context, int? travelId) async {
    if (travelId == null) {
      _errorMessage = 'ID da viagem inválido.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _travel = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedTravel = await _travelRepository.getTravelById(travelId);
      if (fetchedTravel == null) {
        throw Exception('Viagem com ID $travelId não foi encontrada.');
      }
      _travel = fetchedTravel;

      await _loadCommentsAndImages();

      // >> LÓGICA MOVIDA PARA CÁ <<
      // Após carregar tudo, atualizamos o mapa UMA ÚNICA VEZ.
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
    } finally {
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
    // Notifica os listeners no final do método principal
  }
}
