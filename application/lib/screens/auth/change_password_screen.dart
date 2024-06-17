import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
              ),
              TextFormField(
                controller: _confirmPasswordController,
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text("Confirmar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
