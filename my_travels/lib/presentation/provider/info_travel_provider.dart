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
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/services/pdf_generator_service.dart';
import 'package:my_travels/utils/transport_data.dart';
import 'package:provider/provider.dart';

/// Manages the state for the travel details screen.
class InfoTravelProvider extends ChangeNotifier {
  // -- Dependencies --
  final TravelRepository _travelRepository;
  final CommentRepository _commentRepository;
  final DeleteTravelUseCase _deleteTravelUseCase;
  final UpdateTravelStatusUseCase _updateTravelStatusUseCase;

  /// Creates an instance of [InfoTravelProvider].
  InfoTravelProvider({
    required TravelRepository travelRepository,
    required CommentRepository commentRepository,
    required DeleteTravelUseCase deleteTravelUseCase,
    required UpdateTravelStatusUseCase updateTravelStatusUseCase,
  }) : _travelRepository = travelRepository,
       _commentRepository = commentRepository,
       _deleteTravelUseCase = deleteTravelUseCase,
       _updateTravelStatusUseCase = updateTravelStatusUseCase;

  // -- UI State --
  Travel? _travel;
  TransportModel? _vehicleModel;
  List<Comment> _comments = [];
  List<String> _allImagePaths = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _deleteSuccess = false;
  bool _statusUpdateSuccess = false;
  bool _commentSaveSuccess = false;
  int _currentImageIndex = 0;

  // -- Internal Control Variables --
  int? _currentlyLoadedId;
  bool _isFetching = false;

  // -- State for adding a new comment --
  List<File> _selectedImagesForComment = [];
  StopPoint? _selectedStopPointForComment;

  // -- Getters --
  Travel? get travel => _travel;
  TransportModel? get vehicleModel => _vehicleModel;
  List<Comment> get comments => _comments;
  List<String> get allImagePaths => _allImagePaths;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get deleteSuccess => _deleteSuccess;
  bool get statusUpdateSuccess => _statusUpdateSuccess;
  bool get commentSaveSuccess => _commentSaveSuccess;
  int get currentImageIndex => _currentImageIndex;
  List<File> get selectedImagesForComment => _selectedImagesForComment;
  StopPoint? get selectedStopPointForComment => _selectedStopPointForComment;

  // -- Business Logic --

  /// Kicks off the initial fetch for travel details.
  void fetchTravelDetailsIfNeeded(
    BuildContext context,
    int? travelId, {
    bool forceReload = false,
  }) {
    if (travelId == null || _isFetching) return;
    if (!forceReload && _currentlyLoadedId == travelId) return;
    _fetchTravelDetails(context, travelId);
  }

  /// Fetches all details for a given [travelId].
  Future<void> _fetchTravelDetails(BuildContext context, int travelId) async {
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final l10n = AppLocalizations.of(context)!;
      final fetchedTravel = await _travelRepository.getTravelById(travelId);
      if (fetchedTravel == null) {
        throw Exception(l10n.travelNotFound(travelId));
      }
      _travel = fetchedTravel;
      _currentlyLoadedId = travelId;

      _updateVehicleModel(context);
      await _loadCommentsAndImages();

      if (context.mounted) {
        await _updateMapRoute(context);
      }
    } catch (e) {
      _errorMessage = AppLocalizations.of(context)?.errorLoadingTravelDetails;
      _currentlyLoadedId = null;
      // debugPrint('Error fetching travel details: $e');
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves new images as a comment for the current travel.
  Future<void> saveImagesAsComment(AppLocalizations l10n) async {
    _commentSaveSuccess = false;
    _errorMessage = null;

    if (_travel == null || _selectedImagesForComment.isEmpty) return;
    if (_travel!.travelers.isEmpty) {
      _errorMessage = l10n.saveImagesNoTravelers;
      notifyListeners();
      return;
    }

    final stopPointId =
        _selectedStopPointForComment?.id ?? _travel!.stopPoints.first.id;
    if (stopPointId == null) {
      _errorMessage = l10n.saveImagesNoStartPoint;
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
      _commentSaveSuccess = true;
      clearNewCommentFields();
      // The calling UI will be responsible for triggering a reload.
    } catch (e) {
      _errorMessage = l10n.errorSavingImages;
      // debugPrint('Error saving images as comment: $e');
    }
    notifyListeners();
  }

  /// Deletes the current travel.
  Future<void> deleteTravel(AppLocalizations l10n) async {
    if (_travel?.id == null) return;
    _deleteSuccess = false;
    _errorMessage = null;

    try {
      await _deleteTravelUseCase(_travel!.id!);
      _deleteSuccess = true;
    } catch (e) {
      _errorMessage = l10n.errorDeletingTravel;
      // debugPrint("Error in deleteTravel: $e");
    }
    notifyListeners();
  }

  /// Toggles the finished status of the current travel.
  Future<void> toggleTravelStatus(AppLocalizations l10n) async {
    if (_travel == null) return;
    _statusUpdateSuccess = false;
    _errorMessage = null;
    final newStatus = !_travel!.isFinished;

    try {
      await _updateTravelStatusUseCase(
        travelId: _travel!.id!,
        isFinished: newStatus,
      );
      _travel = _travel!.copyWith(isFinished: newStatus);
      _statusUpdateSuccess = true;
    } catch (e) {
      _errorMessage = l10n.errorUpdatingStatus;
      // debugPrint("Error in toggleTravelStatus: $e");
    }
    notifyListeners();
  }

  /// Generates and shares a PDF booklet of the current travel.
  Future<void> generatePdf(GlobalKey mapKey, BuildContext context) async {
    if (travel == null) return;
    _errorMessage = null;
    final l10n = AppLocalizations.of(context)!;

    try {
      final boundary =
          mapKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final mapSnapshot = byteData!.buffer.asUint8List();

      final pdfService = PdfGeneratorService(
        travel: travel!,
        mapSnapshot: mapSnapshot,
        l10n: l10n,
        comments: _comments,
      );
      await pdfService.generateAndShareBooklet();
    } catch (e) {
      _errorMessage = l10n.errorGeneratingPdf;
      notifyListeners();
      // debugPrint("Error in generatePdf: $e");
    }
  }

  // -- UI State Update Methods --

  /// Sets the current index for the image carousel.
  void setCurrentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  /// Clears the fields for a new comment.
  void clearNewCommentFields() {
    _selectedImagesForComment = [];
    _selectedStopPointForComment = null;
    notifyListeners();
  }

  /// Opens the image picker to select multiple images.
  Future<void> pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    _selectedImagesForComment.addAll(
      pickedFiles.map((file) => File(file.path)),
    );
    notifyListeners();
  }

  /// Removes a previously selected image.
  void removeImage(File image) {
    _selectedImagesForComment.remove(image);
    notifyListeners();
  }

  /// Selects a stop point to associate with a new comment.
  void selectStopPoint(StopPoint? stopPoint) {
    _selectedStopPointForComment = stopPoint;
    notifyListeners();
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

  /// Finds the corresponding [TransportModel] for the loaded travel's vehicle string.
  void _updateVehicleModel(BuildContext context) {
    if (_travel?.vehicle == null) {
      _vehicleModel = null;
      return;
    }
    final availableVehicles = getAvailableVehicles(context);
    _vehicleModel = availableVehicles.firstWhere(
      (model) => model.label == _travel!.vehicle,
      // Provide a default empty model to avoid crashing if no match is found.
      orElse: () => TransportModel(label: '', lottieAsset: ''),
    );
  }

  /// Updates the map provider with the route from the current travel's stop points.
  Future<void> _updateMapRoute(BuildContext context) async {
    if (_travel == null) return;

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
}
