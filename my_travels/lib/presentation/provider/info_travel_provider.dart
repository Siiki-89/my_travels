import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/domain/use_cases/travel/delete_travel_use_case.dart';
import 'package:my_travels/domain/use_cases/travel/update_travel_status_use_case.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/location_map_model.dart';
import 'package:my_travels/model/transport_model.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/services/pdf_generator_service.dart';
import 'package:my_travels/utils/transport_data.dart';
import 'package:provider/provider.dart';

class InfoTravelProvider extends ChangeNotifier {
  final TravelRepository _travelRepository;
  final CommentRepository _commentRepository;
  final DeleteTravelUseCase _deleteTravelUseCase;

  // ### AQUI ESTÁ A CORREÇÃO ###
  // 1. Declare a variável para o novo use case.
  final UpdateTravelStatusUseCase _updateTravelStatusUseCase;

  InfoTravelProvider({
    required TravelRepository travelRepository,
    required CommentRepository commentRepository,
  }) : _travelRepository = travelRepository,
       _commentRepository = commentRepository,
       _deleteTravelUseCase = DeleteTravelUseCase(travelRepository),
       // 2. Inicialize o use case no construtor, assim como os outros.
       _updateTravelStatusUseCase = UpdateTravelStatusUseCase(travelRepository);

  // --- ESTADO DA UI ---
  Travel? _travel;
  TransportModel? _vehicleModel;
  List<Comment> _comments = [];
  List<String> _allImagePaths = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentImageIndex = 0;

  // --- VARIÁVEIS DE CONTROLE INTERNO ---
  int? _currentlyLoadedId;
  bool _isFetching = false;

  // --- GETTERS ---
  Travel? get travel => _travel;
  TransportModel? get vehicleModel => _vehicleModel;
  List<Comment> get comments => _comments;
  List<String> get allImagePaths => _allImagePaths;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentImageIndex => _currentImageIndex;

  // --- LÓGICA DE NEGÓCIO ---

  void fetchTravelDetailsIfNeeded(
    BuildContext context,
    int? travelId, {
    bool forceReload = false,
  }) {
    if (travelId == null || _isFetching) return;

    if (!forceReload && _currentlyLoadedId == travelId) {
      return;
    }

    _fetchTravelDetails(context, travelId);
  }

  Future<void> _fetchTravelDetails(BuildContext context, int? travelId) async {
    _isFetching = true;
    _isLoading = true;
    _travel = null;
    notifyListeners();

    try {
      final fetchedTravel = await _travelRepository.getTravelById(travelId!);
      if (fetchedTravel == null) {
        throw Exception('Viagem com ID $travelId não foi encontrada.');
      }
      _travel = fetchedTravel;
      _currentlyLoadedId = travelId;

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
      _currentlyLoadedId = null;
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

  List<File> _selectedImagesForComment = [];
  StopPoint? _selectedStopPointForComment;

  List<File> get selectedImagesForComment => _selectedImagesForComment;
  StopPoint? get selectedStopPointForComment => _selectedStopPointForComment;

  void clearNewCommentFields() {
    _selectedImagesForComment = [];
    _selectedStopPointForComment = null;
    notifyListeners();
  }

  Future<void> pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    _selectedImagesForComment.addAll(
      pickedFiles.map((file) => File(file.path)),
    );
    notifyListeners();
  }

  void removeImage(File image) {
    _selectedImagesForComment.remove(image);
    notifyListeners();
  }

  void selectStopPoint(StopPoint? stopPoint) {
    _selectedStopPointForComment = stopPoint;
    notifyListeners();
  }

  Future<void> saveImagesAsComment(BuildContext context) async {
    if (_travel == null || _selectedImagesForComment.isEmpty) return;
    if (_travel!.travelers.isEmpty) {
      _errorMessage = "Não é possível salvar: a viagem não tem participantes.";
      notifyListeners();
      return;
    }

    final stopPointId =
        _selectedStopPointForComment?.id ?? _travel!.stopPoints.first.id;

    if (stopPointId == null) {
      _errorMessage =
          "Não foi possível salvar: a viagem não tem um ponto de partida.";
      notifyListeners();
      return;
    }

    final newComment = Comment(
      stopPointId: stopPointId,
      content: '',
      travelerId: _travel!.travelers.first.id!,
      photos: _selectedImagesForComment
          .map((file) => CommentPhoto(commentId: 0, imagePath: file.path))
          .toList(),
    );

    try {
      await _commentRepository.insertComment(newComment);
      clearNewCommentFields();
      await _fetchTravelDetails(context, _travel!.id);
    } catch (e) {
      _errorMessage = 'Erro ao salvar as imagens: $e';
      notifyListeners();
    }
  }

  // O método para deletar a viagem agora está correto.
  Future<void> deleteTravel(BuildContext context) async {
    if (_travel?.id == null) return;
    AppLocalizations l10n = AppLocalizations.of(context)!;

    try {
      await _deleteTravelUseCase(_travel!.id!);
      if (context.mounted) {
        Provider.of<HomeProvider>(context, listen: false).fetchTravels(l10n);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _errorMessage = 'Erro ao deletar a viagem: $e';
      notifyListeners();
      debugPrint("Erro em deleteTravel: $e");
    }
  }

  Future<void> toggleTravelStatus(BuildContext context, bool isFinished) async {
    if (_travel == null) return;
    AppLocalizations l10n = AppLocalizations.of(context)!;

    try {
      // 1. Chama o use case para atualizar o status no banco de dados
      await _updateTravelStatusUseCase(
        travelId: _travel!.id!,
        isFinished: isFinished,
      );

      // 2. Atualiza o estado local do objeto 'travel' para refletir a mudança na UI
      _travel = _travel!.copyWith(isFinished: isFinished);

      // ### AQUI ESTÁ A LÓGICA ADICIONADA ###

      // 3. Mostra uma SnackBar de feedback para o usuário
      if (context.mounted) {
        final message = isFinished
            ? 'Viagem marcada como concluída!'
            : 'Viagem reaberta.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 4. Atualiza a lista na HomePage
        // Usamos listen: false pois estamos dentro de um método.
        Provider.of<HomeProvider>(context, listen: false).fetchTravels(l10n);
      }

      // ### FIM DA LÓGICA ADICIONADA ###

      // Notifica os listeners para que a UI (o Switch) se atualize
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao atualizar o status da viagem: $e';
      notifyListeners();
      debugPrint("Erro em toggleTravelStatus: $e");
    }
  }

  Future<void> generatePdf(GlobalKey mapKey, BuildContext context) async {
    if (travel == null) return;

    try {
      // 1. Captura a imagem do widget do mapa
      RenderRepaintBoundary boundary =
          mapKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final mapSnapshot = byteData!.buffer.asUint8List();

      // 2. Cria e chama o serviço de geração de PDF
      final pdfService = PdfGeneratorService(
        travel: travel!,
        mapSnapshot: mapSnapshot,
        l10n: AppLocalizations.of(context)!, // Passa as localizações
        comments: _comments,
      );
      await pdfService.generateAndShareBooklet();
    } catch (e) {
      _errorMessage = 'Erro ao gerar o PDF: $e';
      notifyListeners();
      debugPrint("Erro em generatePdf: $e");
    }
  }
}
