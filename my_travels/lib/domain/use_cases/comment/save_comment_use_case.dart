// Em lib/domain/use_cases/comment/save_comment_use_case.dart

import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';

class SaveCommentUseCase {
  final CommentRepository _repository;
  SaveCommentUseCase(this._repository);

  Future<void> call(Comment comment) async {
    // Regra 1: O autor (Traveler) do comentário deve ser selecionado.
    if (comment.travelerId == null) {
      // Usa a nova exceção correta
      throw InvalidCommentDataException(
        'Por favor, selecione o autor do comentário.',
      );
    }

    // Regra 2: O ponto de parada (StopPoint) deve ser selecionado.
    if (comment.stopPointId == null) {
      // Usa a nova exceção correta
      throw InvalidCommentDataException(
        'Por favor, vincule o comentário a um local da viagem.',
      );
    }
    if (comment.content.isEmpty) {
      throw InvalidCommentDataException('Por favor, digite algo.');
    }

    // Se todas as validações passarem, insere no repositório.
    await _repository.insertComment(comment);
  }
}
