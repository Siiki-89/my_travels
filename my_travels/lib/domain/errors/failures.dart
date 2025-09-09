// Em lib/domain/errors/failures.dart

// ----------------------------------------------------
// Exceções para a validação de uma VIAGEM (Travel)
// ----------------------------------------------------

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

// ----------------------------------------------------
// Exceções para a validação de um VIAJANTE (Traveler)
// ----------------------------------------------------

// Classe base abstrata, assim como a TravelValidationException.
abstract class TravelerValidationException implements Exception {
  final String message;
  TravelerValidationException(this.message);
}

// Classe concreta que pode ser usada para lançar os erros.
class InvalidTravelerDataException extends TravelerValidationException {
  InvalidTravelerDataException(String message) : super(message);
}
