import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/utils/get_user.dart';
import 'package:sp_code/utils/widgets/button.dart';
import 'package:sp_code/view/common/dashboard.dart';
import 'package:sp_code/view/common/sign_up_screen.dart';
import 'package:sp_code/view/common/user_sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});
  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _delayed = true;
  bool _display = false;
  bool isLoggedIn = false;

  checkUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await widget._authService
          .googleRoles(
            user: FirebaseAuth.instance.currentUser!,
            register: false,
          )
          .then((result) {
            UserEntity loggedInUser = getUser.getLoggedInUser(result);
            if (result.role == 'user') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Dashboard(loggedInUser: loggedInUser),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Dashboard(loggedInUser: loggedInUser),
                ),
              );
            }
          });
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2)).then((value) {
      checkUser();
    });

    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (mounted) {
        setState(() {
          _delayed = false;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 3100)).then((value) {
      if (mounted) {
        setState(() {
          _display = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height:
                _delayed
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height / 2.07,
            child: Stack(
              children: [
                Visibility(
                  visible: _delayed,
                  child: Center(
                    child: Image.asset(
                      'assets/images/appIcon.png',
                      height: 150,
                      width: 150,
                    ),
                  ),
                ),
                Visibility(
                  visible: !_delayed,
                  child: Center(
                    child: Image.asset(
                      'assets/images/appIcon.png',
                      height: 150,
                      width: 150,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: _display ? 1 : 0,
            duration: const Duration(seconds: 1),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Visibility(
                  visible: _display,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "eLaw",
                        style: TextStyle(
                          fontSize: 40,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Introducing a simple quiz app for criminal law",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          height: 32 / 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Unlock Your Inner Genius with Every Question!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.grey3,
                        ),
                      ),
                      const SizedBox(height: 50),
                      LargeButton(
                        text: "Sign Up",
                        onClick: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      LargeButton(
                        isEmptyBackground: true,
                        text: "I already have an account",
                        onClick: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserSignInScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
