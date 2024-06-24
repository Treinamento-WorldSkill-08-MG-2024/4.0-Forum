import 'package:flutter/material.dart';

class CommentForm extends StatefulWidget {
  const CommentForm({super.key});

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        TextFormField(),
        OutlinedButton(
          onPressed: () {
            _formKey.currentState!.save();
            if (!_formKey.currentState!.validate()) {
              return;
            }
          },
          child: const Text("Enviar"),
        )
      ],
    ));
  }
}
