// ignore_for_file: unused_local_variable

import 'package:fluttertoast/fluttertoast.dart';
import 'package:sp_code/config/theme.dart';

class GetMessage {
  static getToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: AppTheme.white,
      fontSize: 16.0,
      backgroundColor: AppTheme.red,
    );
  }

  static getErrorMessage(e) {
    String errorMessage = '';
    switch (e.toString().split('.').last) {
      case "invalidEmail":
        return errorMessage = "Invalid email";
      case "userDisabled":
        return errorMessage = "Your account is disabled";
      case "userNotFound":
        return errorMessage = "Account does not exist";
      case "wrongPassword":
        return errorMessage = "Password is wrong";
      case "emailAlreadyInUse":
        return errorMessage = "Email is already in use";
      case "invalidCredential":
        return errorMessage = "Invalid credentials";
      case "operationNotAllowed":
        return errorMessage = "Not Allowed";
      case "weakPassword":
        return errorMessage = "Password is too weak";
      default:
        return errorMessage = "An error occurred";
    }
  }

  static String getGreeting() {
    var hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    }

    return 'Good Evening,';
  }
}
