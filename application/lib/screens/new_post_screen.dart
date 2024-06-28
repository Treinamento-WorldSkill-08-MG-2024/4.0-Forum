import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:application/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: const Text(
          "Nova postagem",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(187, 0, 0, 0),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Styles.defaultSpacing),
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Styles.orange),
              onPressed: () async {
                _formKey.currentState!.save();
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final currentUser =
                    Provider.of<AuthProvider>(context, listen: false)
                        .currentUser;
                if (currentUser == null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                }

                assert(currentUser!.id != null);

                final newPost = PostModel(
                  null,
                  _contentController.text,
                  _titleController.text,
                  true,
                  DateTime.now().toString(),
                  currentUser!.id!,
                );

                final ok = await PublicationHandler.given(newPost)
                    .newPublication(currentUser.id!);

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
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(Styles.defaultSpacing),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Titulo",
                  hintStyle: TextStyle(fontSize: 24),
                ),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                maxLines: 3,
                maxLength: 79,
                controller: _titleController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Conteúdo (opcional)",
                  hintStyle: TextStyle(fontSize: 16),
                ),
                style: const TextStyle(fontSize: 15),
                controller: _contentController,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Styles.foreground,
        height: MediaQuery.of(context).size.height * .085,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.image,
                size: 32,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
