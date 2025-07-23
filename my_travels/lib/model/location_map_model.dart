class LocationMapModel {
  final String locationId;
  final String description;
  final double lat;
  final double long;

  LocationMapModel({
    required this.locationId,
    required this.description,
    required this.lat,
    required this.long,
  });

  factory LocationMapModel.fromJson(Map<String, dynamic> data) {
    return LocationMapModel(
      locationId: data['place_id'] as String,
      description: data['description'] as String,
      lat: (data['geometry']['location']['lat'] as num).toDouble(),
      long: (data['geometry']['location']['lng'] as num).toDouble(),
    );
  }
}
