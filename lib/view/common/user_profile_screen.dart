import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/view/common/splash_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserEntity loggedInUser;
  UserProfileScreen({super.key, required this.loggedInUser});

  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  handleSignOut() async {
    await widget._authService.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            handleSignOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SplashScreen()),
              (Route<dynamic> route) => false,
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
