class Traveler {
  final int? id;
  final String name;
  final int? age;
  final String? photoPath;

  Traveler({this.id, required this.name, this.age, this.photoPath});

  Map<String, dynamic> toMap() {
    final map = {'name': name, 'age': age, 'photoPath': photoPath};
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Traveler.fromMap(Map<String, dynamic> map) {
    return Traveler(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      photoPath: map['photoPath'],
    );
  }

  @override
  String toString() {
    return 'Traveler(id: $id, name: $name, age: $age, photoPath: $photoPath)';
  }
}
