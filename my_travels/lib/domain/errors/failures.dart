// domain/errors/failures.dart

abstract class TravelValidationException implements Exception {
  final String message;
  TravelValidationException(this.message);
}

class InvalidCoverImageException extends TravelValidationException {
  InvalidCoverImageException(String message) : super(message);
}

class InvalidTransportException extends TravelValidationException {
  InvalidTransportException(String message) : super(message);
}

class InvalidTravelersException extends TravelValidationException {
  InvalidTravelersException(String message) : super(message);
}

class InvalidRouteException extends TravelValidationException {
  InvalidRouteException(String message) : super(message);
}
