class Traveler {
  final int? id;
  final String name;
  final int age;
  final String? photoPath;

  Traveler({
    required this.id,
    required this.name,
    required this.age,
    required this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'age': age, 'photoPath': photoPath};
  }

  factory Traveler.fromMap(Map<String, dynamic> map) {
    return Traveler(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      photoPath: map['photoPath'],
    );
  }
}
