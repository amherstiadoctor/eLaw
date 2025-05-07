import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.quizzesTaken,
    required this.quizzesCompleted,
    required this.totalPoints,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final List<String> quizzesTaken;
  final List<String> quizzesCompleted;
  final int totalPoints;

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json['id'] ?? "",
    firstName: json['firstName'] ?? "",
    lastName: json['lastName'] ?? "",
    email: json['email'] ?? "",
    role: json['role'] ?? "",
    quizzesTaken: json['quizzesTaken'] ?? [],
    quizzesCompleted: json['quizzesCompleted'] ?? [],
    totalPoints: json['totalPoints'] ?? 0,
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
  };

  factory UserEntity.empty() => const UserEntity(
    id: "",
    firstName: "",
    lastName: "",
    email: "",
    role: "",
    quizzesTaken: [],
    quizzesCompleted: [],
    totalPoints: 0,
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
    List<String>? quizzesTaken,
    List<String>? quizzesCompleted,
    int? totalPoints,
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
    );
  }
}
