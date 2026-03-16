import 'package:fitnessai/authetication/splash_screen.dart';
import 'package:flutter/material.dart';

import 'notification/notification.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}