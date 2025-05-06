import 'package:firebase_auth/firebase_auth.dart';
import 'package:sp_code/model/user_entity.dart';

abstract class AuthService {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithGoogle();

  Future<UserEntity> googleRoles({required User user, required bool register});

  Future<void> onSignOut();
}
