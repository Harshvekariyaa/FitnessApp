import 'package:flutter/material.dart';

class AppColors {

  // ******* font weight *******
  static const normal = FontWeight.normal;
  static const w300 = FontWeight.w300;
  static const w400 = FontWeight.w400;
  static const w500 = FontWeight.w500;
  static const w600 = FontWeight.w600;
  static const w700 = FontWeight.w700;
  static const bold = FontWeight.bold;

// ******* white ********
  static const white = Colors.white;
  static const white70 = Colors.white70;
  static const white30 = Colors.white30;
  static const white60 = Colors.white60;
  static const white54 = Colors.white54;

// ***** transaperent ******
  static const transparent = Colors.transparent;

// ******** blCK ***********
  static const black = Colors.black;
  static const black12 = Colors.black12;
  static const black26 = Colors.black26;
  static const black38 = Colors.black38;
  static const black45 = Colors.black45;
  static const black54 = Colors.black54;
  static const black87 = Colors.black87;
  static const grey = Colors.grey;


  // 🔵 Primary Brand Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryDark = Color(0xFF000A7F);
  static const Color primaryLight = Color(0xFF3B82F6);

  // 🟢 Secondary / Accent Colors
  static const Color secondary = Color(0xFF22C55E); // Fresh Green
  static const Color secondaryLight = Color(0xFF4ADE80);
  static const Color secondaryDark = Color(0xFF16A34A);

  // ⚪ Background Colors
  static const Color background = Color(0xFFF8FAFC); // Off White
  static const Color scaffoldBackground = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // 📝 Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Dark Navy
  static const Color textSecondary = Color(0xFF334155);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textWhite = Colors.white;

  // 🟦 Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFCBD5E1);

  // 🔘 Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFF94A3B8);

  // 🚦 Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // 🔥 Fitness / AI Accent Colors
  static const Color energyRed = Color(0xFFDC2626);
  static const Color powerOrange = Color(0xFFFB923C);
  static const Color calmBlue = Color(0xFF0EA5E9);
  static const Color progressPurple = Color(0xFF8B5CF6);

  // 🌈 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fitnessGradient = LinearGradient(
    colors: [secondary, powerOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌑 Shadows
  static const Color shadow = Color(0x1A000000);

  //appbar
  static const Color appBarColor = primary;
}



