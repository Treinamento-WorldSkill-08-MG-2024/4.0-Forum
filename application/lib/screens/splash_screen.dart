import 'package:application/modules/auth_modules.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:application/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _apiConnectionFailed = false;

  Future<UserModel?> _helloWorld() async {
    final response =
        await Client().get(Uri.parse('http://10.0.2.2:1323/helloworld'));
    if (response.statusCode != 200) {
      throw Exception("Failed to perform first connection");
    }

    if (!mounted) {
      return null;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.authenticateUser();

    return authProvider.currentUser;
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
