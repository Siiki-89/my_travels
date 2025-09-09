import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';

class NewCommentProvider extends ChangeNotifier {
  // Instancia o próprio repositório, seguindo o seu padrão
  final CommentRepository _commentRepository = CommentRepository();
  final Travel travel;

  final TextEditingController contentController = TextEditingController();
  final _picker = ImagePicker();

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
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedImagePaths.addAll(images.map((img) => img.path));
      notifyListeners();
    }
  }

  void removeImage(String path) {
    selectedImagePaths.remove(path);
    notifyListeners();
  }

  Future<bool> saveComment() async {
    if (selectedTraveler?.id == null ||
        selectedStopPoint?.id == null ||
        contentController.text.trim().isEmpty) {
      // Adicione um feedback para o usuário aqui se desejar
      return false;
    }

    isLoading = true;
    notifyListeners();

    final comment = Comment(
      travelerId: selectedTraveler!.id!,
      stopPointId: selectedStopPoint!.id!,
      content: contentController.text.trim(),
      photos: selectedImagePaths
          .map(
            (path) => CommentPhoto(
              commentId: 0, // O ID será gerado pelo DB
              imagePath: path,
            ),
          )
          .toList(),
    );

    try {
      await _commentRepository.insertComment(comment);
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar comentário: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
