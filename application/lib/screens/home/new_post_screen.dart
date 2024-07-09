import 'dart:io' show File;

import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/modules/storage_module.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:application/screens/home/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// FIXME - Fix state management.
// TODO - Use current user properly
class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  late PageController _pageController;

  List<XFile>? _images;

  @override
  void initState() {
    _pageController =PageController(viewportFraction: .9);
    super.initState();
  }

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
              onPressed: () {
                try {
                  _onSubmit();
                } catch (error) {
                  if (kDebugMode) {
                    print(error);
                  }
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
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _submitImageDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }

    assert(currentUser?.id != null);
    final paths = List<String>.empty(growable: true);

    final storageHandler = StorageHandler(StorageOption.publicaton);
    for (final image in _images ?? List.empty()) {
      final uploaded = await storageHandler.uploadFile(
          File(image.path), currentUser!.id!.toString());
      if (uploaded.isEmpty) {
        if (kDebugMode) {
          print("failed to upload file");
        }
        return;
      }
      paths.add(uploaded);
    }

    final newPost = PostModel(
      null,
      _contentController.text,
      _titleController.text,
      true,
      DateTime.now().toString(),
      currentUser!.id!,
      paths,
    );

    if (!mounted) {
      return;
    }

    final bool ok = await Toasts.unwrapFutureInDialog(
      () => PublicationHandler.given(newPost).newPublication(currentUser.id!),
      context: context,
    );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  AlertDialog _submitImageDialog() {
    return AlertDialog(
      content: Form(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .9,
          height: MediaQuery.of(context).size.height * .6,
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () => _onEditProfilePick(context: context),
                child: const Text(
                  "Selecionar Imagem",
                  style: TextStyle(color: Styles.orange),
                ),
              ),
              if (_images != null)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .5,
                  child: PageView.builder(
                    controller: _pageController,
                    pageSnapping: true,
                    itemCount: _images!.length,
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Image.file(
                        File(_images![index].path),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onEditProfilePick({required BuildContext context}) async {
    if (!context.mounted) {
      return;
    }

    await _displayPickImageDialog(context, (source) async {
      try {
        final List<XFile> imageList = await _imagePicker.pickMultiImage();
        setState(() => _images = imageList);

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop();
        showDialog(context: context, builder: (_) => _submitImageDialog());
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
        setState(() => _images = null);
      }
    });
  }

  Future<void> _displayPickImageDialog(
    BuildContext context,
    void Function(ImageSource) onPick,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => Toasts.imageSourceDialog(context, onPick),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
