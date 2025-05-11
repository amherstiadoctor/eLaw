class Flashcard {

  Flashcard({
    required this.title,
    required this.frontInfo,
    required this.backInfo,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
      title: map['title'] ?? "",
      frontInfo: map['frontInfo'] ?? "",
      backInfo: map['backInfo'] ?? "",
    );
  final String title;
  final String frontInfo;
  final String backInfo;

  Map<String, dynamic> toMap({bool isUpdate = false}) => {'title': title, 'frontInfo': frontInfo, 'backInfo': backInfo};

  Flashcard copyWith({String? title, String? frontInfo, String? backInfo}) => Flashcard(
      title: title ?? this.title,
      frontInfo: frontInfo ?? this.frontInfo,
      backInfo: backInfo ?? this.backInfo,
    );
}
