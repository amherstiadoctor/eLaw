import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xff6a5ae0);
  static const Color primaryTint = Color(0xff9087e5);
  static const Color primaryShade = Color(0xff5b4dc3);
  static const Color secondary = Color(0xfffcc16d);
  static const Color secondaryTint = Color(0xfffcd8a4);
  static const Color secondaryShade = Color(0xfffca62f);
  static const Color tertiary = Color(0xffffb3c0);
  static const Color tertiaryTint = Color(0xffffccd5);
  static const Color tertiaryShade = Color(0xffff8fa2);

  static const Color grey1 = Color(0xffF3F3F3);
  static const Color grey2 = Color(0xffCECECE);
  static const Color grey3 = Color(0xff929292);
  static const Color text = Color(0xFF2D3748);
  static const Color text2 = Color(0xFF718096);
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff040404);
  static const Color red = Color(0xffE57373);
  static const Color green = Color(0xff72bf6a);

  static ThemeData get theme{
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: white,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: text
        )
      ),
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}