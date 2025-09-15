import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';

import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/domain/use_cases/comment/save_comment_use_case.dart';

/// Manages the state for the new comment creation form.
class NewCommentProvider with ChangeNotifier {
  // -- Dependencies --
  final SaveCommentUseCase _saveCommentUseCase;
  final Travel travel;

  /// Creates an instance of [NewCommentProvider].
  ///
  /// Requires the [travel] the comment belongs to and the [saveCommentUseCase]
  /// for business logic, which are injected for testability.
  NewCommentProvider({
    required this.travel,
    required SaveCommentUseCase saveCommentUseCase,
  }) : _saveCommentUseCase = saveCommentUseCase;

  // -- State --
  final TextEditingController contentController = TextEditingController();
  final _picker = ImagePicker();
  Traveler? _selectedTraveler;
  StopPoint? _selectedStopPoint;
  List<String> _selectedImagePaths = [];
  bool _isLoading = false;
  bool _saveSuccess = false;
  String? _errorMessage;

  // -- Getters --
  Traveler? get selectedTraveler => _selectedTraveler;
  StopPoint? get selectedStopPoint => _selectedStopPoint;
  List<String> get selectedImagePaths => _selectedImagePaths;
  bool get isLoading => _isLoading;
  bool get saveSuccess => _saveSuccess;
  String? get errorMessage => _errorMessage;

  // -- Methods --

  /// Selects the author of the comment.
  void selectTraveler(Traveler? traveler) {
    _selectedTraveler = traveler;
    notifyListeners();
  }

  /// Selects the stop point to associate the comment with.
  void selectStopPoint(StopPoint? stopPoint) {
    _selectedStopPoint = stopPoint;
    notifyListeners();
  }

  /// Opens the gallery to pick multiple images.
  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImagePaths.addAll(images.map((img) => img.path));
      notifyListeners();
    }
  }

  /// Removes a previously selected image.
  void removeImage(String path) {
    _selectedImagePaths.remove(path);
    notifyListeners();
  }

  /// Validates and saves the new comment, updating the provider's state.
  Future<void> saveComment(AppLocalizations l10n) async {
    // UI-level validation for immediate feedback.
    if (_selectedTraveler == null) {
      _errorMessage = l10n.errorSelectAuthor;
      notifyListeners();
      return;
    }
    if (_selectedStopPoint == null) {
      _errorMessage = l10n.errorLinkCommentToLocation;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _saveSuccess = false;
    _errorMessage = null;
    notifyListeners();

    final comment = Comment(
      travelerId: _selectedTraveler!.id!,
      stopPointId: _selectedStopPoint!.id!,
      content: contentController.text.trim(),
      photos: _selectedImagePaths
          .map((path) => CommentPhoto(commentId: 0, imagePath: path))
          .toList(),
    );

    try {
      // The Use Case handles the core business rule validations.
      await _saveCommentUseCase(comment, l10n);
      _saveSuccess = true;
    } on InvalidCommentException catch (e) {
      _errorMessage = e.message;
      // Re-throw for the UI to catch and show the specific validation message.
      throw e;
    } catch (e) {
      _errorMessage = l10n.errorSavingComment;
      // debugPrint('Error saving comment: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
