import 'package:application/components/arch_form_field.dart';
import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:application/utils/extensions.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(Styles.defaultSpacing),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    "Bem vindo ao Forum!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("Comece inserindo suas informações cadastrais"),
                  const SizedBox(height: Styles.defaultSpacing * 4),
                  _form(),
                ],
              ),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Padding _submitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: Styles.defaultSpacing * 2),
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
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Continuar",
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

  Form _form() {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          ArchFormField(
            hintText: "Nome",
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Preencha o formulários antes de enviar-lo';
              }

              return null;
            },
          ),
          const SizedBox(height: Styles.defaultSpacing),
          ArchFormField(
            hintText: "Email",
            controller: _emailController,
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
            hintText: "Senha",
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Preencha o formulários antes de enviar-lo';
              }

              return null;
            },
          ),
        ],
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

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
