import 'dart:io';

import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;

  final _imagePicker = ImagePicker();
  XFile? _image;

  @override
  Widget build(BuildContext context) {
    _currentUser ??=
        Provider.of<AuthProvider>(context, listen: false).currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CircleAvatar(),
            OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _changeProfilePictureDialog(),
              ),
              child: const Text("Editar"),
            ),
            Text(_currentUser!.name),
            const SizedBox(height: Styles.defaultSpacing),
            Row(
              children: [
                TextButton(onPressed: () {}, child: const Text("Publicações")),
                TextButton(onPressed: () {}, child: const Text("Comentários")),
                TextButton(onPressed: () {}, child: const Text("Sobre")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AlertDialog _changeProfilePictureDialog() {
    return AlertDialog(
      content: Form(
        child: Column(
          children: [
            OutlinedButton(
              onPressed: () => _onEditProfilePick(context: context),
              child: const Text("Selecionar Image"),
            ),
            _image != null
                ? Image.file(File(_image!.path))
                : const SizedBox.shrink(),
            OutlinedButton(
              onPressed: _image != null ? _onSubmitPicture : null,
              child: const Text("Enviar"),
            )
          ],
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
        final XFile? media = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1000,
          maxHeight: 1000,
          imageQuality: 100,
        );

        if (media != null) {
          setState(() => _image = media);
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    });
  }

  Future<void> _displayPickImageDialog(
    BuildContext context,
    void Function(ImageSource) onPick,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                onPick(ImageSource.camera);
                Navigator.of(context).pop();
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                onPick(ImageSource.gallery);
                Navigator.of(context).pop();
              },
              child: const Text("Galeria"),
            ),
          ],
        );
      },
    );
  }

  void _onSubmitPicture() async {
    if (_image == null || _currentUser == null) {
      if (kDebugMode) {
        print("Either image or currentUser are null");
      }
      // Failed
      return;
    }

    final ok = await UserHandler()
        .uploadProfilePic(File(_image!.path), _currentUser!.id!);
    if (!ok) {
      if (kDebugMode) {
        print("Response not ok");
      }
    }

    Toasts.successDialog("ok");
  }
}
