class Traveler {
  const Traveler({this.id, required this.name, this.age, this.photoPath});

  final int? id;
  final String name;
  final int? age;
  final String? photoPath;

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'age': age, 'photoPath': photoPath};
  }

  factory Traveler.fromMap(Map<String, dynamic> map) {
    return Traveler(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int?,
      photoPath: map['photoPath'] as String?,
    );
  }
}
