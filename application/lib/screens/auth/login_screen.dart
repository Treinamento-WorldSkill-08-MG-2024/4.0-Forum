import 'package:application/components/arch_form_field.dart';
import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
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
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            child: const Text(
              "sign up",
              style: TextStyle(
                fontSize: 15,
                color: Styles.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Styles.defaultSpacing),
          child: Column(
            children: [
              const Text(
                "Insira suas informações de login",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Styles.defaultSpacing * 4),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ArchFormField(
                            controller: _emailController,
                            hintText: "Email",
                          ),
                          const SizedBox(height: Styles.defaultSpacing),
                          ArchFormField(
                            controller: _passwordController,
                            hintText: "Senha",
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(),
                              ),
                            ),
                            child: const Text(
                              "Esqueci minha senha",
                              style: TextStyle(
                                fontSize: 15,
                                color: Styles.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: Styles.defaultSpacing * 2,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Ao continuar, você estará aceitando nossos termos e condições do usuário.",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Styles.defaultSpacing),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: _onSubmit,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Styles.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Text(
                                        "Entrar",
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
                ),
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
      final ok = await _authHandler.login(
        context,
        _emailController.text,
        _passwordController.text,
      );

      if (!ok) {
        throw Exception("Tente novamente mais tarde");
      }

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

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }

      showDialog(
        context: context,
        builder: (_) => Toasts.failureDialog(
            "Houve um erro ao realizar o login: ${error.toString()}"),
      );
    }
  }
}
