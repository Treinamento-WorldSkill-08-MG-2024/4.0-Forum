import 'package:application/components/arch_form_field.dart';
import 'package:application/components/toats.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  final String _code;
  final int _id;

  ChangePasswordScreen(this._code, this._id, {super.key});

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
              ArchFormField(
                controller: _passwordController,
              ),
              ArchFormField(
                controller: _confirmPasswordController,
              ),
              OutlinedButton(
                onPressed: () => _onSubmit(context),
                child: const Text("Confirmar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context) async {
    _formKey.currentState!.save();

    try {
      final ok = await AuthHandler().changePassword(_id, _code, _confirmPasswordController.text);

      if (!ok) {
        throw Exception("Tente novamente mais tarde");
      }

      if (!context.mounted) {
        return;
      }

      await showDialog(
        context: context,
        builder: (_) => Toasts.successDialog("Logged In."),
      );

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }

      showDialog(
        context: context,
        builder: (_) => Toasts.failureDialog(
            "Houve um erro ao enviar email: ${error.toString()}"),
      );
    }
  }
}
