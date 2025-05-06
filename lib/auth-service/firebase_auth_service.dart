import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/model/auth_error.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/repository/user_repository.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({required auth.FirebaseAuth authService})
    : _firebaseAuth = authService;

  final auth.FirebaseAuth _firebaseAuth;
  final userRepo = Get.put(UserRepository());
  final _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserEntity> _mapFirebaseUser(auth.User? user, bool register) async {
    String userRole = '';
    if (user == null) {
      return UserEntity.empty();
    }

    var splittedName = ['Name ', 'LastName'];
    if (user.displayName != null) {
      splittedName = user.displayName!.split(' ');
    }

    if (!register) {
      await _db
          .collection("Users")
          .where("email", isEqualTo: user.email)
          .get()
          .then((querySnapshot) {
            userRole = querySnapshot.docs[0].data()["role"];
          }, onError: (e) => print("Error completing: $e"));
    }

    final map = <String, dynamic>{
      'id': user.uid,
      'firstName': splittedName.first,
      'lastName': splittedName.last,
      'email': user.email ?? '',
      'emailVerified': user.emailVerified,
      'role': userRole.isNotEmpty ? userRole : "user",
    };

    if (register) {
      userRepo.createUser(UserEntity.fromJson(map));
    }

    return UserEntity.fromJson(map);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _mapFirebaseUser(userCredential.user!, false);
    } on auth.FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firebaseAuth.currentUser!.updateDisplayName(
        "$firstName $lastName",
      );

      return _mapFirebaseUser(_firebaseAuth.currentUser!, true);
    } on auth.FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  @override
  Future<auth.UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    var result = await _firebaseAuth.signInWithCredential(credential);

    return result;
  }

  @override
  Future<UserEntity> googleRoles({
    required auth.User user,
    required bool register,
  }) async {
    return _mapFirebaseUser(user, register);
  }

  @override
  Future<void> onSignOut() async {
    await _firebaseAuth.signOut().then((value) {
      _googleSignIn.signOut();
    });
  }

  AuthError _determineError(auth.FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return AuthError.invalidEmail;
      case 'user-disabled':
        return AuthError.userDisabled;
      case 'user-not-found':
        return AuthError.userNotFound;
      case 'wrong-password':
        return AuthError.wrongPassword;
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return AuthError.emailAlreadyInUse;
      case 'invalid-credential':
        return AuthError.invalidCredential;
      case 'operation-not-allowed':
        return AuthError.operationNotAllowed;
      case 'weak-password':
        return AuthError.weakPassword;
      case 'ERROR_MISSING_GOOGLE_AUTH_TOKEN':
      default:
        return AuthError.error;
    }
  }
}
