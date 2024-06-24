import 'package:application/modules/publications_modules.dart';
import 'package:application/screens/home_screen.dart';
import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              _formKey.currentState!.save();
              if (!_formKey.currentState!.validate()) {
                return;
              }

              final newPost = PostModel(
                null,
                _contentController.text,
                _titleController.text,
                true,
                DateTime.now().toString(),
                2,
                0,
                0,
              );
              final ok = await PublicationHandler().newPost(2, newPost);

              if (!context.mounted) {
                return;
              }

              if (ok) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
            ),
            TextFormField(
              controller: _contentController,
            ),
          ],
        ),
      ),
    );
  }
}
