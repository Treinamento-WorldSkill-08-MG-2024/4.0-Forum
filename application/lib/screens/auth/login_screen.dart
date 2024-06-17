import 'package:application/components/toats.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/forgot_password_screen.dart';
import 'package:application/screens/auth/register_screen.dart';
import 'package:application/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authHandler = AuthHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
              ),
              TextFormField(
                controller: _passwordController,
              ),
              OutlinedButton(onPressed: _onSubmit, child: const Text("Entrar")),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                ),
                child: const Text("Esqueci minha senha"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text("Não possuo cadastro"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = await _authHandler.login(
          _emailController.text, _passwordController.text);

      if (!mounted) {
        return;
      }

      await showDialog(
        context: context,
        builder: (_) => Toasts.successDialog("Logged In."),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

      if (kDebugMode) {
        print(user);
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }

      showDialog(
        context: context,
        builder: (_) =>
            Toasts.failureDialog("Houve um erro ao realizar o login: ${error.toString()}"),
      );
    }
  }
}
