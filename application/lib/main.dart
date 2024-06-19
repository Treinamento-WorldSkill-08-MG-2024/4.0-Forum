import 'package:application/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // Use provider for authentication
  @override
  Widget build(BuildContext context) {  
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}
