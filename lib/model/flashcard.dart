import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    final timestamp = map['nextReviewDate'];
    final nextReviewDate =
        timestamp != null
            ? (timestamp is Timestamp ? timestamp.toDate() : DateTime.now())
            : DateTime.now();
    return Flashcard(
      level: map['level'] ?? 0,
      frontInfo: map['frontInfo'] ?? "",
      backInfo: map['backInfo'] ?? "",
      id: map['id'] ?? "",
      nextReviewDate: nextReviewDate,
    );
  }
  Flashcard({
    this.level = 0,
    required this.frontInfo,
    required this.backInfo,
    required this.id,
    required this.nextReviewDate,
  });

  final String id;
  int level;
  final String frontInfo;
  final String backInfo;
  final DateTime nextReviewDate;

  Map<String, dynamic> toMap({bool isUpdate = false}) => {
    'level': level,
    'frontInfo': frontInfo,
    'backInfo': backInfo,
    'id': id,
    'nextReviewDate': nextReviewDate,
  };

  Flashcard copyWith({
    int? level,
    String? frontInfo,
    String? backInfo,
    DateTime? nextReviewDate,
  }) => Flashcard(
    id: id,
    level: level ?? 0,
    frontInfo: frontInfo ?? this.frontInfo,
    backInfo: backInfo ?? this.backInfo,
    nextReviewDate: nextReviewDate ?? this.nextReviewDate,
  );
}
