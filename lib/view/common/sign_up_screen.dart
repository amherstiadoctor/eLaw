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

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String errorMessage = 'Please fill in the fields';
  String firstNameInput = '';
  String lastNameInput = '';
  String emailInput = '';
  String passwordInput = '';
  String reenteredPasswordInput = '';

  handleSignUp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (passwordInput != reenteredPasswordInput) {
      GetMessage.getToastMessage("Entered passwords do not match");
    } else if (firstNameInput.isEmpty ||
        lastNameInput.isEmpty ||
        emailInput.isEmpty ||
        passwordInput.isEmpty ||
        reenteredPasswordInput.isEmpty) {
      GetMessage.getToastMessage("Plese fill in all the fields");
    } else {
      try {
        await widget._authService
            .signUpWithEmailAndPassword(
              firstName: firstNameInput,
              lastName: lastNameInput,
              email: emailInput,
              password: passwordInput,
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
      } catch (e) {
        GetMessage.getErrorMessage(e);

        GetMessage.getToastMessage(errorMessage);
      }
    }
  }

  handleGoogleSignUp() async {
    try {
      await widget._authService.signInWithGoogle().then((value) async {
        await widget._authService
            .googleRoles(user: value.user!, register: false)
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
      });
    } catch (e) {
      errorMessage = GetMessage.getErrorMessage(e);

      GetMessage.getToastMessage(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Header(title: "Create Account"),
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 100.responsiveH),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SvgPicture.string(signUpIcon, height: 150, width: 150),
                    const SizedBox(height: 15),
                    Text(
                      "Sign Up",
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
                            label: "First Name",
                            placeholder: "Enter your first name",
                            onTextChange: (value) {
                              setState(() {
                                firstNameInput = value;
                              });
                            },
                          ),
                          Input(
                            label: "Last Name",
                            placeholder: "Enter your last name",
                            onTextChange: (value) {
                              setState(() {
                                lastNameInput = value;
                              });
                            },
                          ),
                          Input(
                            label: "Email",
                            placeholder: "Enter your email",
                            onTextChange: (value) {
                              setState(() {
                                emailInput = value;
                              });
                            },
                          ),
                          Input(
                            label: "Password",
                            placeholder: "Enter your password",
                            isPasswordField: true,
                            onTextChange: (value) {
                              setState(() {
                                passwordInput = value;
                              });
                            },
                          ),
                          Input(
                            label: "Re-enter Password",
                            placeholder: "Re-enter your password",
                            isPasswordField: true,
                            onTextChange: (value) {
                              setState(() {
                                reenteredPasswordInput = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          LargeButton(text: "Sign Up", onClick: handleSignUp),
                          const OrDivider(),
                          GestureDetector(
                            onTap: () {
                              handleGoogleSignUp();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
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
}
