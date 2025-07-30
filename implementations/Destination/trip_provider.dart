// trip_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar a data

/// Representa um único destino na viagem.
class Destination {
  // Usamos um ID único para facilitar a atualização de um item específico na lista.
  final int id;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? arrivalDate;
  DateTime? departureDate;

  Destination({required this.id});

  // Método para liberar os controllers e evitar vazamentos de memória.
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}

/// O nosso gerenciador de estado (ChangeNotifier).
class TripProvider with ChangeNotifier {
  final TextEditingController startLocationController = TextEditingController();
  final List<Destination> _destinations = [];
  int _nextId = 0;

  TripProvider() {
    // Começa com um destino inicial, conforme solicitado.
    addDestination();
  }

  List<Destination> get destinations => _destinations;

  /// Adiciona um novo destino à lista.
  void addDestination() {
    _destinations.add(Destination(id: _nextId++));
    // Notifica todos os 'ouvintes' (a UI) que o estado mudou.
    notifyListeners();
  }

  /// Atualiza a data de chegada de um destino específico.
  void updateArrivalDate(int id, DateTime date) {
    final destination = _destinations.firstWhere((d) => d.id == id);
    destination.arrivalDate = date;
    notifyListeners();
  }

  /// Atualiza a data de partida de um destino específico.
  void updateDepartureDate(int id, DateTime date) {
    final destination = _destinations.firstWhere((d) => d.id == id);
    destination.departureDate = date;
    notifyListeners();
  }

  /// Calcula a duração da estadia em um destino.
  String calculateDuration(Destination destination) {
    if (destination.arrivalDate != null && destination.departureDate != null) {
      // Garante que a data de partida seja depois da chegada.
      if (destination.departureDate!.isAfter(destination.arrivalDate!)) {
        final difference = destination.departureDate!.difference(
          destination.arrivalDate!,
        );
        // Retorna "1 dia" se for apenas um dia.
        if (difference.inDays == 1) {
          return '1 dia';
        }
        return '${difference.inDays} dias';
      }
      return 'Data inválida';
    }
    return 'Não calculado';
  }

  /// Formata a data para exibição na UI.
  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Selecione a data';
    }
    // Para usar 'pt_BR', certifique-se de configurar a localização no main.dart
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Método fundamental para limpar todos os controllers quando o Provider for descartado.
  @override
  void dispose() {
    startLocationController.dispose();
    for (var destination in _destinations) {
      destination.dispose();
    }
    super.dispose();
  }
}
