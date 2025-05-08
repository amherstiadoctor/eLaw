class Flashcard {
  final String title;
  final String frontInfo;
  final String backInfo;

  Flashcard({
    required this.title,
    required this.frontInfo,
    required this.backInfo,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      title: map['title'] ?? "",
      frontInfo: map['frontInfo'] ?? "",
      backInfo: map['backInfo'] ?? "",
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {'title': title, 'frontInfo': frontInfo, 'backInfo': backInfo};
  }

  Flashcard copyWith({String? title, String? frontInfo, String? backInfo}) {
    return Flashcard(
      title: title ?? this.title,
      frontInfo: frontInfo ?? this.frontInfo,
      backInfo: backInfo ?? this.backInfo,
    );
  }
}
