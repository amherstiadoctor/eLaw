import 'package:equatable/equatable.dart';
import 'package:sp_code/model/taken_quiz.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.quizzesTaken,
    this.quizzesCompleted,
    required this.totalPoints,
    required this.friends,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final List<TakenQuiz>? quizzesTaken;
  final List<String>? quizzesCompleted;
  final int totalPoints;
  final List<String> friends;

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json['id'] ?? "",
    firstName: json['firstName'] ?? "",
    lastName: json['lastName'] ?? "",
    email: json['email'] ?? "",
    role: json['role'] ?? "",
    quizzesTaken:
        ((json['quizzesTaken'] ?? []) as List)
            .map((e) => TakenQuiz.fromMap(e))
            .toList(),
    quizzesCompleted:
        ((json['quizzesCompleted'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
    totalPoints: json['totalPoints'] ?? 0,
    friends:
        ((json['friends'] ?? []) as List).map((e) => e.toString()).toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
    'quizzesTaken': quizzesTaken,
    'quizzesCompleted': quizzesCompleted,
    'totalPoints': totalPoints,
    'friends': friends,
  };

  factory UserEntity.empty() => UserEntity(
    id: "",
    firstName: "",
    lastName: "",
    email: "",
    role: "",
    quizzesTaken: [],
    quizzesCompleted: [],
    totalPoints: 0,
    friends: [],
  );

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    role,
    quizzesTaken,
    quizzesCompleted,
    totalPoints,
  ];

  UserEntity copyWith({
    List<String>? quizzesCompleted,
    List<TakenQuiz>? quizzesTaken,
    int? totalPoints,
    List<String>? friends,
  }) {
    return UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalPoints: totalPoints ?? this.totalPoints,
      friends: friends ?? this.friends,
    );
  }
}
