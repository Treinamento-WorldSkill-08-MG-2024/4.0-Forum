import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Forgot Screen"),
              TextFormField(
                controller: _emailController,
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text("Enviar email de recuperação"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
