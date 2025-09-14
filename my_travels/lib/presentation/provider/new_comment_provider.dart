import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/domain/use_cases/comment/save_comment_use_case.dart';

class NewCommentProvider extends ChangeNotifier {
  // Use Case para a lógica de negócio
  final SaveCommentUseCase _saveCommentUseCase;

  final Travel travel;

  // Estado da UI
  final TextEditingController contentController = TextEditingController();
  final _picker = ImagePicker();
  Traveler? selectedTraveler;
  StopPoint? selectedStopPoint;
  List<String> selectedImagePaths = [];
  bool isLoading = false;

  // O provider agora recebe o repositório para criar o UseCase
  NewCommentProvider({required this.travel})
    : _saveCommentUseCase = SaveCommentUseCase(CommentRepository());

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

  /// Salva o comentário. Retorna `true` se for bem-sucedido.
  /// Lida com a exibição de erros para o usuário.
  /* Future<bool> saveComment(BuildContext context) async {
    // --- VALIDAÇÃO DOS CAMPOS OBRIGATÓRIOS ---
    // A validação agora acontece ANTES de qualquer outra coisa.
    if (selectedTraveler == null) {
      _showErrorSnackBar(
        context,
        'Por favor, selecione o autor do comentário.',
      );
      return false;
    }

    if (selectedStopPoint == null) {
      _showErrorSnackBar(
        context,
        'Por favor, vincule o comentário a um local da viagem.',
      );
      return false;
    }
    // --- FIM DA VALIDAÇÃO ---

    isLoading = true;
    notifyListeners();

    // Agora que já validamos, podemos usar '!' com segurança para
    // garantir ao Dart que os valores não são nulos.
    final comment = Comment(
      travelerId: selectedTraveler!.id!,
      stopPointId: selectedStopPoint!.id!,
      content: contentController.text.trim(),
      photos: selectedImagePaths
          .map((path) => CommentPhoto(commentId: 0, imagePath: path))
          .toList(),
    );

    try {
      // Delega a validação de CONTEÚDO para o UseCase
      await _saveCommentUseCase(comment);
      return true;
    } on InvalidCommentDataException catch (e) {
      _showErrorSnackBar(context, e.message);
      return false;
    } catch (e) {
      debugPrint('Erro ao salvar comentário: $e');
      _showErrorSnackBar(context, 'Ocorreu um erro inesperado.');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  } */

  // Não se esqueça de ter um método para mostrar a SnackBar no seu provider
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
