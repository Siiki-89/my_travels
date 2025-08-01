import 'package:my_travels/model/location_map_model.dart';

class DestinationModel {
  final int id;
  final LocationMapModel? location;
  final String? description;
  final DateTime? arrivalDate;
  final DateTime? departureDate;

  DestinationModel({
    required this.id,
    this.location,
    this.description,
    this.arrivalDate,
    this.departureDate,
  });

  DestinationModel copyWith({
    LocationMapModel? location,
    String? description,
    DateTime? arrivalDate,
    DateTime? departureDate,
  }) {
    return DestinationModel(
      id: id,
      location: location ?? this.location,
      description: description ?? this.description,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureDate: departureDate ?? this.departureDate,
    );
  }
}
