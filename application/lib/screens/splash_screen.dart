import 'package:application/screens/auth/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _apiConnectionFailed = false;

  Future<void> _helloWorld() async {
    final response =
        await Client().get(Uri.parse('http://10.0.2.2:1323/helloworld'));
    if (response.statusCode != 200) {
      throw Exception("Failed to perform first connection");
    }
  }

  @override
  void initState() {
    _helloWorld()
        .then(
          (_) => Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
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
