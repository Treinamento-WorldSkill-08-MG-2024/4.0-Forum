import 'dart:io';

import 'package:application/components/profile_pic.dart';
import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/modules/storage_module.dart';
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
  final _imagePicker = ImagePicker();

  UserModel? _currentUser;
  XFile? _image;
  int selected = 0;

  @override
  void didChangeDependencies() {
    _currentUser = null;
    _image = null;
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _currentUser = null;
    _image = null;
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    _currentUser ??=
        Provider.of<AuthProvider>(context, listen: false).currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.orange,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _changeProfilePictureDialog(),
            ),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              color: Styles.orange,
              child: Padding(
                padding: const EdgeInsets.all(Styles.defaultSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(builder: (context) {
                      if (_currentUser != null) {
                        return GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => _changeProfilePictureDialog(),
                          ),
                          child: ProfilePic(
                            _currentUser!.profilePic,
                            width: MediaQuery.of(context).size.height * .1,
                            height: MediaQuery.of(context).size.height * .1,
                          ),
                        );
                      }

                      return ProfilePic(
                        _currentUser!.profilePic,
                        width: MediaQuery.of(context).size.height * .1,
                        height: MediaQuery.of(context).size.height * .1,
                      );
                    }),
                    const SizedBox(height: Styles.defaultSpacing),
                    Text(
                      _currentUser!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Styles.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: Styles.defaultSpacing),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("Publicações",
                      style: TextStyle(fontSize: 16, color: Styles.black)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Comentários",
                      style: TextStyle(fontSize: 16, color: Styles.black)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Curtidos",
                      style: TextStyle(fontSize: 16, color: Styles.black)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Sobre",
                      style: TextStyle(fontSize: 16, color: Styles.black)),
                ),
              ],
            ),

            const SizedBox(height: Styles.defaultSpacing),

            // ANCHOR - Contents
            Builder(builder: (_) {
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  AlertDialog _changeProfilePictureDialog() {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .6,
          minHeight: MediaQuery.of(context).size.height * .2,
        ),
        child: Form(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () => _onEditProfilePick(context: context),
                    child: const Text(
                      "Editar",
                      style: TextStyle(color: Styles.orange),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _image != null ? _onSubmitPicture : null,
                    child: const Text(
                      "Enviar",
                      style: TextStyle(color: Styles.orange),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Styles.defaultSpacing),
              Builder(builder: (_) {
                if (_currentUser?.profilePic != null && _image == null) {
                  return Image.network(
                      StorageHandler.fmtImageUrl(_currentUser!.profilePic!));
                }

                if (_image != null) {
                  return Image.file(File(_image!.path));
                }

                return const SizedBox.shrink();
              }),
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
        final XFile? media = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1000,
          maxHeight: 1000,
          imageQuality: 100,
        );

        if (media != null) {
          setState(() => _image = media);
          if (!context.mounted) {
            return;
          }

          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (_) => _changeProfilePictureDialog(),
          );
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
        setState(() => _image = null);
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

  void _onSubmitPicture() async {
    if (_image == null || _currentUser == null) {
      if (kDebugMode) {
        print("Either image or currentUser are null");
      }
      // Failed
      return;
    }

    final ok = await UserHandler().uploadProfilePic(
      File(_image!.path),
      _currentUser!.id!,
      context: context,
    );
    if (!ok) {
      if (kDebugMode) {
        print("Response not ok");
      }
    }

    setState(() {
      _currentUser = null;
    });
    Toasts.successDialog("ok");
  }
}
