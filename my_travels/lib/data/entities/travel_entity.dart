// Em lib/data/entities/travel_entity.dart

import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/tables/travel_table.dart';

class Travel {
  final int? id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? vehicle;
  final String? coverImagePath;
  final List<StopPoint> stopPoints;
  final List<Traveler> travelers;
  // ### 1. PROPRIEDADE ADICIONADA ###
  final bool isFinished;

  const Travel({
    this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.vehicle,
    this.coverImagePath,
    this.stopPoints = const [],
    this.travelers = const [],
    // ### 2. CONSTRUTOR ATUALIZADO ###
    required this.isFinished,
  });

  // ### 3. MÉTODO toMap ATUALIZADO ###

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'vehicle': vehicle,
      'cover_image_path': coverImagePath,
      'is_finished': isFinished ? 1 : 0,
      // stopPoints e travelers geralmente são salvos em tabelas separadas
    };
  }

  // ### 4. MÉTODO fromMap ATUALIZADO ###
  factory Travel.fromMap(
    Map<String, dynamic> map, {
    List<StopPoint>? stopPoints,
    List<Traveler>? travelers,
  }) {
    return Travel(
      id: map['id'],
      title: map['title'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      vehicle: map['vehicle'],
      coverImagePath: map['cover_image_path'],
      stopPoints: stopPoints ?? [],
      travelers: travelers ?? [],
      // Converte o inteiro do banco (0 ou 1) para booleano
      isFinished: map[TravelTable.isFinished] == 1,
    );
  }

  // ### 5. MÉTODO copyWith ADICIONADO (BOA PRÁTICA) ###
  Travel copyWith({
    int? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? vehicle,
    String? coverImagePath,
    List<StopPoint>? stopPoints,
    List<Traveler>? travelers,
    bool? isFinished,
  }) {
    return Travel(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      vehicle: vehicle ?? this.vehicle,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      stopPoints: stopPoints ?? this.stopPoints,
      travelers: travelers ?? this.travelers,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
