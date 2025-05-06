import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sp_code/model/user_entity.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createUser(UserEntity user) async {
    await _db.collection("Users").add(user.toJson()).catchError((
      error,
      stackTrace,
    ) {
      print(error.ToString());
    });
  }
}
