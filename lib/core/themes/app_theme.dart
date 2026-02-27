import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3B82F6);

  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightTextColor = Color(0xFF101828);
  static const Color lightSubTextColor = Color(0xFF4A5565);
  static const Color lightGreyColor = Color(0xFFCDCCD0);
  static const Color lightOutlineColor = Color(0xFFD1D5DC);

  static const Color darkBackgroundColor = Color(0xFF0B0F0E);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkSubTextColor = Color(0xFF99A1AF);
  static const Color darkGreyColor = Color(0xFF3A3D3D);

  static const Color hintTextColor = Color(0xFF6A7282);

  static const Color transparentColor = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color borderColor = Color(0xFFF3F4F6);

  static const Color green = Color(0xFF00C950);
  static const Color red = Color(0xFFE7000B);
  static const Color lightRed = Color(0xFFFEF2F2);
  static const Color orange = Color(0xFFE17100);
  static const Color lightOrange = Color(0xFFFFFBEB);
  static const Color purple = Color(0xFF9810FA);

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF60A5FA)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient greenGradient = const LinearGradient(
    colors: [Color(0xff00B894), Color(0xff00E676), Color(0xff00B894)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient redGradient = const LinearGradient(
    colors: [Color(0xFFFB2C36), Color(0xFFFF6900), Color(0xFFFB2C36)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient purpleGradient = const LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient orangeGradient = const LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFFFB74D), Color(0xFFF97316)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.light,
    primaryIconTheme: IconThemeData(color: lightSubTextColor),
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      outline: lightOutlineColor,
      surfaceContainerHigh: lightBackgroundColor,
      inverseSurface: lightGreyColor,
    ),
    iconTheme: IconThemeData(color: black, size: 20.sp),
    cardColor: white,
    dividerColor: borderColor,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      titleLarge: GoogleFonts.roboto(
        fontSize: 30.sp,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),

      labelLarge: GoogleFonts.roboto(
        fontSize: 30.sp,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 24.sp,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),

      headlineLarge: GoogleFonts.roboto(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),

      bodyLarge: GoogleFonts.roboto(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: lightSubTextColor,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: lightSubTextColor,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: lightSubTextColor,
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: darkGreyColor,
      linearTrackColor: lightGreyColor,
      linearMinHeight: 10.h,
      borderRadius: BorderRadius.circular(50.r),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF3F4F6),
      hintStyle: TextStyle(color: hintTextColor, fontSize: 16.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: lightOutlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: lightOutlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: lightOutlineColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: red.withValues(alpha: 0.6)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.dark,
    primaryIconTheme: IconThemeData(color: darkSubTextColor),
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      outline: white.withValues(alpha: 0.20),
      surfaceContainerHigh: darkBackgroundColor,
      inverseSurface: white,
    ),
    iconTheme: IconThemeData(color: white, size: 20.sp),
    cardColor: black.withValues(alpha: 0.40),
    dividerColor: white.withValues(alpha: 0.10),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      titleLarge: GoogleFonts.roboto(
        fontSize: 30.sp,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),

      labelLarge: GoogleFonts.roboto(
        fontSize: 30.sp,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 24.sp,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),

      headlineLarge: GoogleFonts.roboto(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),

      bodyLarge: GoogleFonts.roboto(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: darkSubTextColor,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: darkSubTextColor,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: darkSubTextColor,
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: white,
      linearTrackColor: darkGreyColor,
      linearMinHeight: 10.h,
      borderRadius: BorderRadius.circular(50.r),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: transparentColor,
      hintStyle: TextStyle(color: hintTextColor, fontSize: 16.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: white.withValues(alpha: 0.1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: red.withValues(alpha: 0.6)),
      ),
    ),
  );
}
