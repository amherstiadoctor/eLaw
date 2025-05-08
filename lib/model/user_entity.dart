import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.quizzesCompleted,
    required this.totalPoints,
    required this.decks,
    required this.friends,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final List<String> quizzesCompleted;
  final int totalPoints;
  final List<String> decks;
  final List<String> friends;

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json['id'] ?? "",
    firstName: json['firstName'] ?? "",
    lastName: json['lastName'] ?? "",
    email: json['email'] ?? "",
    role: json['role'] ?? "",
    quizzesCompleted: json['quizzesCompleted'] ?? [],
    totalPoints: json['totalPoints'] ?? 0,
    decks: json['decks'] ?? [],
    friends: json['friends'] ?? [],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
    'quizzesCompleted': quizzesCompleted,
    'totalPoints': totalPoints,
    'decks': decks,
    'friends': friends,
  };

  factory UserEntity.empty() => const UserEntity(
    id: "",
    firstName: "",
    lastName: "",
    email: "",
    role: "",
    quizzesCompleted: [],
    totalPoints: 0,
    decks: [],
    friends: [],
  );

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    role,
    quizzesCompleted,
    totalPoints,
    decks,
  ];

  UserEntity copyWith({
    List<String>? quizzesCompleted,
    int? totalPoints,
    List<String>? decks,
    List<String>? friends,
  }) {
    return UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalPoints: totalPoints ?? this.totalPoints,
      decks: decks ?? this.decks,
      friends: friends ?? this.friends,
    );
  }
}
