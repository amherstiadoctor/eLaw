import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/firebase_options.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/view/common/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "eLaw",
      theme: AppTheme.theme,
      home: SplashScreen(),
    );
}
