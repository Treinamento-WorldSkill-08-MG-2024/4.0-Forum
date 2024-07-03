import 'dart:io' show File;

import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/modules/storage_module.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:application/screens/auth/login_screen.dart';
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

  UserModel? _currentUser;
  List<XFile>? _images;

  void _setImageFileListFromFile(XFile? value) {
    _images = value == null ? null : <XFile>[value];
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
                  print(error);
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

    assert(currentUser!.id != null);

    final storageHandler = StorageHandler(StorageOption.publicaton);
    for (final image in _images!) {
      final uploaded = await storageHandler.uploadFile(
          File(image.path), _currentUser!.id!.toString());
      print(uploaded);
      if (uploaded.isEmpty) {
        if (kDebugMode) {
          print("failed to upload file");
        }
        return;
      }
    }

    print(_images);
    print(_images!.map((file) => file.path).toList());
    final newPost = PostModel(
      null,
      _contentController.text,
      _titleController.text,
      true,
      DateTime.now().toString(),
      currentUser!.id!,
      _images!.map((file) => file.path).toList(),
    );

    // final ok =
    //     await PublicationHandler.given(newPost).newPublication(currentUser.id!);

    // if (!mounted) {
    //   return;
    // }

    // if (ok) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (_) => const HomeScreen()),
    //   );
    // }
  }

  AlertDialog _submitImageDialog() {
    return AlertDialog(
      content: Form(
        child: SizedBox(
          width: 800,
          height: 800,
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () => _onEditProfilePick(context: context),
                child: const Text("Selecionar Image"),
              ),
              _images != null
                  ? SizedBox(
                      child: Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _images!.length,
                          itemBuilder: (_, index) {
                            return Image.file(File(_images![index].path));
                          },
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
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
