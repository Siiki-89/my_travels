import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/l10n/app_localizations.dart';

/// A use case responsible for validating and saving a comment.
class SaveCommentUseCase {
  /// The repository that handles the data layer operations for comments.
  final CommentRepository _repository;

  /// Creates an instance of [SaveCommentUseCase].
  const SaveCommentUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Validates the [comment] and uses [l10n] for error messages.
  Future<void> call(Comment comment, AppLocalizations l10n) async {
    // Rule 1: The comment must be linked to a traveler.
    if (comment.travelerId <= 0) {
      throw InvalidCommentException(l10n.errorSelectAuthor);
    }

    // Rule 2: The comment must be linked to a stop point.
    if (comment.stopPointId <= 0) {
      throw InvalidCommentException(l10n.errorLinkCommentToLocation);
    }

    // Rule 3: The comment content must not be empty.
    if (comment.content.trim().isEmpty) {
      throw InvalidCommentException(l10n.errorCommentEmpty);
    }

    // Rule 4: The comment must not exceed the maximum length.
    if (comment.content.length > 280) {
      throw InvalidCommentException(l10n.errorCommentTooLong);
    }

    // If all validations pass, insert into the repository.
    await _repository.insertComment(comment);
  }
}
