import 'package:application/components/arch_form_field.dart';
import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/change_password_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _emailSent = false;
  int _userID = -1;

  @override
  void didChangeDependencies() {
    _emailSent = false;
    _userID = -1;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Styles.defaultSpacing),
          child: Column(
            children: [
              const Text(
                "Insira seu email",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Styles.defaultSpacing * 4),
              _form(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _form() {
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
                  controller: _emailController,
                  hintText: "Email",
                  borderSide:
                      _emailSent ? const BorderSide(color: Colors.green) : null,
                ),
                _emailSent ? const Text("sent") : const SizedBox.shrink(),
                const SizedBox(height: Styles.defaultSpacing),
                _emailSent
                    ? ArchFormField(
                        controller: _codeController,
                        hintText: "Código de verificação",
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: Styles.defaultSpacing * 2,
              ),
              child: _submitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Column _submitButton() {
    return Column(
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
    );
  }

  void _onSubmit() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_emailSent) {
      await _validateCode();
      return;
    }

    await _sendEmail();
  }

  Future _validateCode() async {
    try {
      final ok = await AuthHandler().validate(_userID, _codeController.text);

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

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(_codeController.text, _userID),
      ));
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

  Future _sendEmail() async {
    try {
      final ok = await AuthHandler().forgot(_emailController.text);

      if (ok == null) {
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

      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => const HomeScreen()),
      // );
      print(ok);
      setState(() {
        _userID = ok;
        _emailSent = true;
      });
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }

      showDialog(
        context: context,
        builder: (_) => Toasts.failureDialog(
            "Houve um erro ao enviar email: ${error.toString()}"),
      );

      setState(() {
        _emailSent = false;
      });
    }
  }
}
