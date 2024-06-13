import 'package:application/screens/forgot_password_screen.dart';
import 'package:application/screens/register_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
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
    );
  }

  void _onSubmit() {
    _formKey.currentState!.save();
  }
}
