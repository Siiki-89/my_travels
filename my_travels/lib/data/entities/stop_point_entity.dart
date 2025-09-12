/// Represents a specific stop point within a travel itinerary.
class StopPoint {
  /// Creates a stop point instance.
  const StopPoint({
    this.id,
    required this.travelId,
    required this.stopOrder,
    required this.locationName,
    this.latitude,
    this.longitude,
    this.description,
    this.arrivalDate,
    this.departureDate,
  });

  /// The unique identifier of the stop point.
  final int? id;

  /// The ID of the travel this stop point belongs to.
  final int travelId;

  /// The sequential order of this stop within the travel.
  final int stopOrder;

  /// The name of the location for this stop point.
  final String locationName;

  /// The geographic latitude of the stop point.
  final double? latitude;

  /// The geographic longitude of the stop point.
  final double? longitude;

  /// A text description of the stop point.
  final String? description;

  /// The date and time of arrival at the stop point.
  final DateTime? arrivalDate;

  /// The date and time of departure from the stop point.
  final DateTime? departureDate;

  /// Converts this StopPoint instance to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'travel_id': travelId,
      'stop_order': stopOrder,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'arrival_date': arrivalDate?.toIso8601String(),
      'departure_date': departureDate?.toIso8601String(),
    };
  }

  /// Creates a StopPoint instance from a map retrieved from the database.
  factory StopPoint.fromMap(Map<String, dynamic> map) {
    final arrivalDateString = map['arrival_date'] as String?;
    final departureDateString = map['departure_date'] as String?;

    return StopPoint(
      id: map['id'] as int?,
      travelId: map['travel_id'] as int,
      stopOrder: map['stop_order'] as int,
      locationName: map['location_name'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      description: map['description'] as String?,
      arrivalDate: arrivalDateString != null
          ? DateTime.parse(arrivalDateString)
          : null,
      departureDate: departureDateString != null
          ? DateTime.parse(departureDateString)
          : null,
    );
  }

  /// Creates a copy of this StopPoint with the given fields replaced with new values.
  StopPoint copyWith({
    int? id,
    int? travelId,
    int? stopOrder,
    String? locationName,
    double? latitude,
    double? longitude,
    String? description,
    DateTime? arrivalDate,
    DateTime? departureDate,
  }) {
    return StopPoint(
      id: id ?? this.id,
      travelId: travelId ?? this.travelId,
      stopOrder: stopOrder ?? this.stopOrder,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureDate: departureDate ?? this.departureDate,
    );
  }
}
