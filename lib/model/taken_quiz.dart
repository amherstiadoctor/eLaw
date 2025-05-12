import 'package:cloud_firestore/cloud_firestore.dart';

class TakenQuiz {
  TakenQuiz({required this.quizId, required this.quizScore, this.takenAt});

  factory TakenQuiz.fromMap(Map<String, dynamic> map) => TakenQuiz(
    quizId: map['quizId'] ?? "",
    quizScore: map['quizScore'] ?? 0,
    takenAt:
        map['takenAt'] is Timestamp
            ? (map['takenAt'] as Timestamp).toDate()
            : DateTime.now(),
  );
  final String quizId;
  double quizScore;
  DateTime? takenAt;

  Map<String, dynamic> toMap({bool isUpdate = false}) => {
    'quizId': quizId,
    'quizScore': quizScore,
    'takenAt': isUpdate ? DateTime.now() : takenAt,
  };

  TakenQuiz copyWith({double? quizScore}) =>
      TakenQuiz(quizId: quizId, quizScore: quizScore ?? this.quizScore);
}
