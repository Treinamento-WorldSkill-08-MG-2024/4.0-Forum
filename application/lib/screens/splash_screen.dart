import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:application/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _apiConnectionFailed = false;

  Future<Object?> _helloWorld() async {
    final prefs = await SharedPreferences.getInstance();

    final response =
        await Client().get(Uri.parse('http://10.0.2.2:1323/helloworld'));
    if (response.statusCode != 200) {
      throw Exception("Failed to perform first connection");
    }

    final token = prefs.get(UserModelFields.token);
    if (token == null) {
      return null;
    }

    // TODO - Authnetiate user then redirect him to the home screen

    return prefs.get(UserModelFields.token);
  }

  @override
  void initState() {
    _helloWorld()
        .then(
          (user) => user == null 
            ? Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()))
            : Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()))
        )
        .catchError((error) { 
          setState(() => _apiConnectionFailed = true);

          if (kDebugMode) {
            print(error);
          }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            _apiConnectionFailed ? _errorScreen() : _splashScreen(),
          ],
        ),
      ),
    );
  }

  Widget _splashScreen() {
    return const Text("Splash Screen");
  }

  Widget _errorScreen() {
    return const Text("Failed");
  }
}
