import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';

class Travel {
  final int? id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? vehicle;
  final String? coverImagePath;
  final List<StopPoint> stopPoints;
  final List<Traveler> travelers;

  Travel({
    this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.vehicle,
    this.coverImagePath,
    this.stopPoints = const [],
    this.travelers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'vehicle': vehicle,
      'cover_image_path': coverImagePath,
    };
  }

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
    );
  }
}
