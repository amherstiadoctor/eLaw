import 'package:sp_code/model/user_entity.dart';

class getUser {
  static getLoggedInUser(UserEntity userValue) {
    return UserEntity(
      id: userValue.role,
      firstName: userValue.firstName,
      lastName: userValue.lastName,
      email: userValue.email,
      role: userValue.role,
      quizzesCompleted: userValue.quizzesCompleted,
      totalPoints: userValue.totalPoints,
      decks: userValue.decks,
      friends: userValue.friends,
    );
  }
}
