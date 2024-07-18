import 'dart:io';

import 'package:application/components/posts/publicatons_feed.dart';
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
  final int _profileID;
  const ProfileScreen({super.key, required int profileID})
      : _profileID = profileID;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _imagePicker = ImagePicker();

  UserModel? _user;
  XFile? _image;
  int selected = 0;

  @override
  void didChangeDependencies() {
    _user = null;
    _image = null;
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _user = null;
    _image = null;
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser;
    _user = currentUser?.id == widget._profileID ? currentUser : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.orange,
        leading: const BackButton(color: Colors.white),
        actions: [
          if (_user != null && _user?.id == widget._profileID)
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _changeProfilePictureDialog(),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
            )
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profileHeader(),

            const SizedBox(height: Styles.defaultSpacing),

            // ANCHOR - Views bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("Publicações",
                      style: TextStyle(fontSize: 16, color: Styles.orange, fontWeight: FontWeight.bold)),
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
            Builder(builder: (context) {
              if (_user?.id == widget._profileID) {
                return PublicationsFeed(userID: _user?.id);
              }

              return FutureBuilder<UserModel>(
                future: UserHandler().getUserData(widget._profileID),
                builder: (_, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                        "Houve um erro ao carregar os dados do usário");
                  }

                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    _user = snapshot.data!;

                    return PublicationsFeed(
                      userID: _user?.id,
                    );
                  }

                  return const CircularProgressIndicator(color: Styles.orange);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Styles.orange,
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_userDataConsumer()],
        ),
      ),
    );
  }

  Consumer<AuthProvider> _userDataConsumer() {
    return Consumer<AuthProvider>(
      builder: (context, value, child) {
        if (_user != null) {
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => _changeProfilePictureDialog(),
            ),
            child: child!,
          );
        }

        return FutureBuilder<UserModel>(
          future: UserHandler().getUserData(widget._profileID),
          builder: (_, snapshot) {
            if (snapshot.hasError) {
              return const Text("Houve um erro ao carregar os dados do usário");
            }

            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              _user = snapshot.data!;

              return child!;
            }

            return const CircularProgressIndicator(color: Styles.orange);
          },
        );
      },
      child: Builder(builder: (_) {
        return Column(
          children: [
            ProfilePic(
              _user?.profilePic,
              width: MediaQuery.of(context).size.height * .1,
              height: MediaQuery.of(context).size.height * .1,
            ),
            const SizedBox(height: Styles.defaultSpacing),
            Text(
              _user?.name ?? 'loading',
              style: const TextStyle(
                fontSize: 24,
                color: Styles.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
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
                if (_user?.profilePic != null && _image == null) {
                  return Image.network(
                    StorageHandler.fmtImageUrl(_user!.profilePic!),
                  );
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
    if (_image == null || _user == null) {
      if (kDebugMode) {
        print("Either image or currentUser are null");
      }
      // Failed
      return;
    }

    final ok = await UserHandler().uploadProfilePic(
      File(_image!.path),
      _user!.id!,
      context: context,
    );
    if (!ok) {
      if (kDebugMode) {
        print("Response not ok");
      }
    }

    setState(() {
      _user = null;
    });
    Toasts.successDialog("ok");
  }
}
