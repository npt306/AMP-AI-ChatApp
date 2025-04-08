import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/homepage_screen/homepage_screen.dart';

import 'package:amp_ai_chatapp/screens/my_bot_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Monica Auth',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   primaryColor: const Color(0xFF8A70FF),
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF8A70FF),
      //     primary: const Color(0xFF8A70FF),
      //   ),
      //   inputDecorationTheme: InputDecorationTheme(
      //     filled: true,
      //     fillColor: const Color(0xFFF2F4F7),
      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(12),
      //       borderSide: const BorderSide(color: Color(0xFF8A70FF)),
      //     ),
      //     enabledBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(12),
      //       borderSide: const BorderSide(color: Color(0xFF8A70FF)),
      //     ),
      //     focusedBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(12),
      //       borderSide: const BorderSide(color: Color(0xFF8A70FF), width: 2),
      //     ),
      //     errorBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(12),
      //       borderSide: const BorderSide(color: Colors.red),
      //     ),
      //     contentPadding: const EdgeInsets.symmetric(
      //       horizontal: 16,
      //       vertical: 16,
      //     ),
      //   ),
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: const Color(0xFF8A70FF),
      //       foregroundColor: Colors.white,
      //       minimumSize: const Size(double.infinity, 56),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(28),
      //       ),
      //       elevation: 0,
      //       textStyle: const TextStyle(
      //         fontSize: 18,
      //         fontWeight: FontWeight.w500,
      //       ),
      //     ),
      //   ),
      // ),
      home: const LoginScreen(),
    );
  }
}
