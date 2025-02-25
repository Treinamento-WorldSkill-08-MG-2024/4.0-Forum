import 'package:application/components/arch_form_field.dart';
import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/forgot_password_screen.dart';
import 'package:application/screens/auth/register_screen.dart';
import 'package:application/screens/home/home_screen.dart';
import 'package:application/utils/extensions.dart';
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
              _form(context),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _form(BuildContext context) {
    return Expanded(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ArchFormField(
                  inputType: TextInputType.emailAddress,
                  controller: _emailController,
                  hintText: "Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o formulários antes de enviar-lo';
                    }

                    if (!value.isValidEmail()) {
                      return 'Email invalido';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: Styles.defaultSpacing),
                ArchFormField(
                  inputType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  hintText: "Senha",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o formulários antes de enviar-lo';
                    }

                    return null;
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
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
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Padding _submitButton() {
    return Padding(
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
                  onPressed: () async => await _onSubmit(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Styles.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Future<void> _onSubmit() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final ok = await Toasts.unwrapFutureInDialog(
        () => _authHandler.login(
          context,
          _emailController.text,
          _passwordController.text,
        ),
        context: context,
      );
      if (!ok) {
        throw Exception("Tente novamente mais tarde");
      }

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

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      showDialog(
        context: context,
        builder: (_) => Toasts.failureDialog(
            "Houve um erro ao realizar o login: ${error.toString()}"),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
