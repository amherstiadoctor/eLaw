import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/svg_images.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/utils/get_user.dart';
import 'package:sp_code/utils/widgets/button.dart';
import 'package:sp_code/utils/widgets/fields.dart';
import 'package:sp_code/utils/widgets/header.dart';
import 'package:sp_code/utils/widgets/or_divider.dart';
import 'package:sp_code/view/common/dashboard.dart';

class UserSignInScreen extends StatefulWidget {
  UserSignInScreen({super.key});

  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<UserSignInScreen> createState() => _UserSignInScreenState();
}

class _UserSignInScreenState extends State<UserSignInScreen> {
  String errorMessage = 'Please fill in the fields';
  String emailInput = '';
  String passwordInput = '';

  handleSignIn() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (emailInput.isEmpty || passwordInput.isEmpty) {
      GetMessage.getToastMessage("Plese fill in all the fields");
    } else {
      try {
        await widget._authService
            .signInWithEmailAndPassword(
              email: emailInput,
              password: passwordInput,
            )
            .then((value) {
              final UserEntity loggedInUser = GetUser.getLoggedInUser(value);
              if (value.role == "user") {
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Dashboard(loggedInUser: loggedInUser),
                  ),
                  (route) => false,
                );
              } else {
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Dashboard(loggedInUser: loggedInUser),
                  ),
                  (route) => false,
                );
              }
            });
      } catch (e) {
        errorMessage = GetMessage.getErrorMessage(e);

        GetMessage.getToastMessage(errorMessage);
      }
    }
  }

  handleGoogleSignIn() async {
    try {
      await widget._authService.signInWithGoogle().then((value) async {
        await widget._authService
            .googleRoles(user: value.user!, register: false)
            .then((result) {
              final UserEntity loggedInUser = GetUser.getLoggedInUser(result);
              if (result.role == 'user') {
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Dashboard(loggedInUser: loggedInUser),
                  ),
                  (route) => false,
                );
              } else {
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Dashboard(loggedInUser: loggedInUser),
                  ),
                  (route) => false,
                );
              }
            });
      });
    } catch (e) {
      errorMessage = GetMessage.getErrorMessage(e);

      GetMessage.getToastMessage(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    body: Stack(
      children: [
        const Header(title: "Sign Into Account", hasBackButton: true),
        Center(
          child: Container(
            padding: EdgeInsets.only(top: 100.responsiveH),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SvgPicture.string(signInIcon, height: 150, width: 150),
                  const SizedBox(height: 15),
                  const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        Input(
                          label: "Email",
                          placeholder: "Enter your email",
                          onTextChange: (value) {
                            emailInput = value;
                          },
                        ),
                        Input(
                          label: "Password",
                          placeholder: "Enter your password",
                          isPasswordField: true,
                          onTextChange: (value) {
                            passwordInput = value;
                          },
                        ),
                        const SizedBox(height: 20),
                        LargeButton(text: "Sign In", onClick: handleSignIn),
                        const OrDivider(),
                        GestureDetector(
                          onTap: () {
                            handleGoogleSignIn();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: AppTheme.primary,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.string(
                              googleIcon,
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
