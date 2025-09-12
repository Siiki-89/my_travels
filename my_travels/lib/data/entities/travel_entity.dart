import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';

/// Represents a travel itinerary with its details and associated data.
class Travel {
  /// Creates a travel instance.
  const Travel({
    this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.vehicle,
    this.coverImagePath,
    this.stopPoints = const [],
    this.travelers = const [],
    required this.isFinished,
  });

  /// The unique identifier of the travel.
  final int? id;

  /// The title of the travel.
  final String title;

  /// The start date of the travel.
  final DateTime startDate;

  /// The end date of the travel.
  final DateTime endDate;

  /// The vehicle used for the travel (e.g., car, plane).
  final String? vehicle;

  /// The local file path for the travel's cover image.
  final String? coverImagePath;

  /// A list of stop points associated with this travel.
  final List<StopPoint> stopPoints;

  /// A list of travelers associated with this travel.
  final List<Traveler> travelers;

  /// A flag indicating if the travel has been completed.
  final bool isFinished;

  /// Converts this Travel instance to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'vehicle': vehicle,
      'cover_image_path': coverImagePath,
      'is_finished': isFinished ? 1 : 0,
    };
  }

  /// Creates a Travel instance from a map retrieved from the database.
  factory Travel.fromMap(
    Map<String, dynamic> map, {
    List<StopPoint>? stopPoints,
    List<Traveler>? travelers,
  }) {
    return Travel(
      id: map['id'] as int?,
      title: map['title'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      vehicle: map['vehicle'] as String?,
      coverImagePath: map['cover_image_path'] as String?,
      stopPoints: stopPoints ?? [],
      travelers: travelers ?? [],
      isFinished: (map[TravelTable.isFinished] as int) == 1,
    );
  }

  /// Creates a copy of this Travel with the given fields replaced with new values.
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
