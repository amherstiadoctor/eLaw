import 'package:sp_code/model/user_entity.dart';

class GetUser {
  static getLoggedInUser(UserEntity userValue) => UserEntity(
      id: userValue.role,
      firstName: userValue.firstName,
      lastName: userValue.lastName,
      email: userValue.email,
      role: userValue.role,
      quizzesTaken: userValue.quizzesTaken,
      quizzesCompleted: userValue.quizzesCompleted,
      totalPoints: userValue.totalPoints,
      friends: userValue.friends,
    );
}
