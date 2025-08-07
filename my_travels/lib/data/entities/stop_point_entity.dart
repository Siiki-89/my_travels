class StopPoint {
  final int? id;
  final int travelId;
  final int stopOrder;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String? description;
  final DateTime? arrivalDate;
  final DateTime? departureDate;

  StopPoint({
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

  factory StopPoint.fromMap(Map<String, dynamic> map) {
    return StopPoint(
      id: map['id'],
      travelId: map['travel_id'],
      stopOrder: map['stop_order'],
      locationName: map['location_name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      description: map['description'],
      arrivalDate: map['arrival_date'] != null
          ? DateTime.parse(map['arrival_date'])
          : null,
      departureDate: map['departure_date'] != null
          ? DateTime.parse(map['departure_date'])
          : null,
    );
  }
}
