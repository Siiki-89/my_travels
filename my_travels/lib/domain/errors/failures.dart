// Exceptions for Travel validation
abstract class TravelValidationException implements Exception {
  /// A user-friendly error message.
  final String message;

  /// Creates a travel validation exception.
  const TravelValidationException(this.message);
}

/// Thrown when the travel's cover image is invalid.
class InvalidCoverImageException extends TravelValidationException {
  /// Creates an instance of [InvalidCoverImageException].
  const InvalidCoverImageException(String message) : super(message);
}

/// Thrown when the travel's transport method is invalid.
class InvalidTransportException extends TravelValidationException {
  /// Creates an instance of [InvalidTransportException].
  const InvalidTransportException(String message) : super(message);
}

/// Thrown when the travel's list of travelers is invalid.
class InvalidTravelersException extends TravelValidationException {
  /// Creates an instance of [InvalidTravelersException].
  const InvalidTravelersException(String message) : super(message);
}

/// Thrown when the travel's route (stop points) is invalid.
class InvalidRouteException extends TravelValidationException {
  /// Creates an instance of [InvalidRouteException].
  const InvalidRouteException(String message) : super(message);
}

// Exceptions for Traveler validation
abstract class TravelerValidationException implements Exception {
  /// A user-friendly error message.
  final String message;

  /// Creates a traveler validation exception.
  const TravelerValidationException(this.message);
}

/// Thrown for generic invalid traveler data.
class InvalidTravelerException extends TravelerValidationException {
  /// Creates an instance of [InvalidTravelerException].
  const InvalidTravelerException(String message) : super(message);
}

// Exceptions for Comment validation
abstract class CommentValidationException implements Exception {
  /// A user-friendly error message.
  final String message;

  /// Creates a comment validation exception.
  const CommentValidationException(this.message);
}

/// Thrown for generic invalid comment data.
class InvalidCommentException extends CommentValidationException {
  /// Creates an instance of [InvalidCommentException].
  const InvalidCommentException(String message) : super(message);
}
