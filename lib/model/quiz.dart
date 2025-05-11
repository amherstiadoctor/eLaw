import 'package:sp_code/model/question.dart';

class Quiz {

  Quiz({
    required this.id,
    required this.title,
    required this.difficultyId,
    required this.timeLimit,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) => Quiz(
      id: id,
      title: map['title'] ?? "",
      difficultyId: map['difficultyId'] ?? "",
      timeLimit: map['timeLimit'] ?? 0,
      questions:
          ((map['questions'] ?? []) as List)
              .map((e) => Question.fromMap(e))
              .toList(),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  final String id;
  final String title;
  final String difficultyId;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap({bool isUpdate = false}) => {
      'title': title,
      'difficultyId': difficultyId,
      'timeLimit': timeLimit,
      'questions': questions.map((e) => e.toMap()).toList(),
      if (isUpdate) 'updatedAt': DateTime.now(),
      'createdAt': createdAt,
    };

  Quiz copyWith({
    String? title,
    String? difficultyId,
    int? timeLimit,
    List<Question>? questions,
    DateTime? createdAt,
  }) => Quiz(
      id: id,
      title: title ?? this.title,
      difficultyId: difficultyId ?? this.difficultyId,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt,
    );
}
