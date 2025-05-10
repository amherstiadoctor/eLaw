import 'package:cloud_firestore/cloud_firestore.dart';

class TakenQuiz {
  final String quizId;
  double quizScore;
  DateTime? takenAt;

  TakenQuiz({required this.quizId, required this.quizScore, this.takenAt});

  factory TakenQuiz.fromMap(Map<String, dynamic> map) {
    return TakenQuiz(
      quizId: map['quizId'] ?? "",
      quizScore: map['quizScore'] ?? 0,
      takenAt:
          map['takenAt'] is Timestamp
              ? (map['takenAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'quizId': quizId,
      'quizScore': quizScore,
      if (isUpdate) 'takenAt': DateTime.now(),
    };
  }

  TakenQuiz copyWith({double? quizScore}) {
    return TakenQuiz(quizId: quizId, quizScore: quizScore ?? this.quizScore);
  }
}
