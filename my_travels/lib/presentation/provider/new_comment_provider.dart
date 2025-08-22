// new_comment_provider.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';

class NewCommentProvider extends ChangeNotifier {
  final CommentRepository _commentRepository = CommentRepository();
  final Travel travel;
  final TextEditingController contentController = TextEditingController();

  Traveler? selectedTraveler;
  StopPoint? selectedStopPoint;
  List<String> selectedImagePaths = [];
  bool isLoading = false;

  NewCommentProvider({required this.travel});

  void selectTraveler(Traveler? traveler) {
    selectedTraveler = traveler;
    notifyListeners();
  }

  void selectStopPoint(StopPoint? stopPoint) {
    selectedStopPoint = stopPoint;
    notifyListeners();
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      selectedImagePaths.addAll(images.map((img) => img.path));
      notifyListeners();
    }
  }

  void removeImage(String path) {
    selectedImagePaths.remove(path);
    notifyListeners();
  }

  Future<void> saveComment() async {
    if (selectedTraveler == null ||
        selectedStopPoint == null ||
        contentController.text.isEmpty) {
      // Retorne ou mostre um erro se os campos obrigatórios não estiverem preenchidos
      return;
    }

    isLoading = true;
    notifyListeners();

    final comment = Comment(
      travelerId: selectedTraveler!.id!,
      stopPointId: selectedStopPoint!.id!,
      content: contentController.text,
      photos: selectedImagePaths
          .map(
            (path) => CommentPhoto(
              commentId: 0, // Será atualizado pelo repositório
              imagePath: path,
            ),
          )
          .toList(),
    );

    await _commentRepository.insertComment(comment);
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
