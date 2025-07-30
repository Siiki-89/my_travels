import 'package:my_travels/model/location_map_model.dart';

class DestinationModel {
  final int id;
  LocationMapModel? location;
  String? description;
  DateTime? arrivalDate;
  DateTime? departureDate;
  bool isEditing;

  DestinationModel({
    required this.id,
    this.location,
    this.description,
    this.arrivalDate,
    this.departureDate,
    this.isEditing = true,
  });
}
