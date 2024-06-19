import 'package:application/components/toats.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authHandler = AuthHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Center(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
              ),
              TextFormField(
                controller: _emailController,
              ),
              TextFormField(
                controller: _passwordController,
              ),
              OutlinedButton(onPressed: _onSubmit, child: const Text("Entrar")),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    _formkey.currentState!.save();
    if (!_formkey.currentState!.validate()) {
      // TODO -
      return;
    }

    try {
      final ok = await _authHandler.register(UserModel(
        null,
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      ));

      if (!ok) {
        throw Exception("Tente novamente mais tarde");
      }

      if (!mounted) {
        return;
      }

      await showDialog(
          context: context,
          builder: (_) => Toasts.successDialog("Conta criado com sucesso"));

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (error) {
      if (!mounted) {
        return;
      }

      showDialog(
        context: context,
        builder: (_) => Toasts.failureDialog(
            "Houve um erro ao cadastrar seu usuário: $error"),
      );
    }
  }
}
