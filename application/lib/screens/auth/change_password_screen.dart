import 'package:application/components/arch_form_field.dart';
import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
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
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Styles.defaultSpacing),
          child: Column(
            children: [
              const Text(
                "Insira suas nova senha",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Styles.defaultSpacing * 4),
              Expanded(
                child: _form(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Form _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: Styles.defaultSpacing * 2,
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    ArchFormField(
                      hintText: "Nova senha",
                      controller: _passwordController,
                    ),
                    const SizedBox(height: Styles.defaultSpacing),
                    ArchFormField(
                      hintText: "Confirme sua senha",
                      controller: _confirmPasswordController,
                    ),
                  ],
                ),
                const SizedBox(height: Styles.defaultSpacing),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _onSubmit(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: Styles.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Confirmar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmit(BuildContext context) async {
    _formKey.currentState!.save();

    try {
      final ok = await AuthHandler()
          .changePassword(_id, _code, _confirmPasswordController.text);

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
