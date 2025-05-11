class Difficulty {

  Difficulty({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
  });

  factory Difficulty.fromMap(String id, Map<String, dynamic> map) => Difficulty(
      id: id,
      name: map['name'],
      description: map['description'],
      createdAt: map['createdAt']?.toDate(),
    );
  final String id;
  final String name;
  final String description;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
      'name': name,
      'description': description,
      'createdAt': createdAt ?? DateTime.now(),
    };

  Difficulty copyWith({String? name, String? description}) => Difficulty(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
    );
}
