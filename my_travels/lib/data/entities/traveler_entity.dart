/// Represents a traveler in the application.
class Traveler {
  /// Creates a traveler instance.
  const Traveler({this.id, required this.name, this.age, this.photoPath});

  /// The unique identifier of the traveler.
  final int? id;

  /// The name of the traveler.
  final String name;

  /// The age of the traveler.
  final int? age;

  /// The local file path for the traveler's photo.
  final String? photoPath;

  /// Converts this Traveler instance to a map for database storage.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'age': age, 'photoPath': photoPath};
  }

  /// Creates a Traveler instance from a map retrieved from the database.
  factory Traveler.fromMap(Map<String, dynamic> map) {
    return Traveler(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int?,
      photoPath: map['photoPath'] as String?,
    );
  }

  /// Creates a copy of this Traveler with the given fields replaced with new values.
  Traveler copyWith({int? id, String? name, int? age, String? photoPath}) {
    return Traveler(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
