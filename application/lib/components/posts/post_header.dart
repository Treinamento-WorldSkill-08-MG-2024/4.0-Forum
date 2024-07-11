import 'package:application/components/profile_pic.dart';
import 'package:application/components/toats.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostHeader extends StatefulWidget {
  final PostModel _post;

  const PostHeader(this._post, {super.key});

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader> {
  late final Future<UserModel> _authorFuture;

  @override
  void initState() {
    _authorFuture = UserHandler().getUserData(widget._post.authorID);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FutureBuilder(
          future: _authorFuture,
          builder: (_, snapshot) {
            if (snapshot.hasError) {
              if (kDebugMode) {
                print(snapshot.error!);
              }
            }

            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return _userInfoRow(snapshot.data!);
            }

            return const CircularProgressIndicator();
          },
        ),
        Consumer<AuthProvider>(builder: (context, value, _) {
          assert(value.currentUser != null);

          return PopupMenuButton(
            itemBuilder: (_) => [
              if (value.currentUser!.id == widget._post.authorID)
                PopupMenuItem(
                  child: const Text("Apagar publicação"),
                  onTap: () async {
                    try {
                      final _ = await PublicationHandler.given(widget._post)
                          .deletePost();
                      if (!context.mounted) {
                        return;
                      }
                      Toasts.unwrapFutureInDialog(
                        context: context,
                        () => Navigator.of(context).popAndPushNamed('/home'),
                      );
                    } catch (error) {
                      if (kDebugMode) {
                        print(
                            "FAILURE AT POST HEADER DELETE ITEM POPUP MENU:\n$error");
                      }
                    }
                  },
                ),
              if (value.currentUser!.id == widget._post.authorID)
                PopupMenuItem(
                  child: const Text("Editar publicação"),
                  onTap: () {},
                )
              else
                PopupMenuItem(
                  child: const Text("Denunciar"),
                  onTap: () {},
                )
            ],
          );
        })
      ],
    );
  }

  Widget _userInfoRow(UserModel user) {
    return Row(
      children: [
        ProfilePic(
          user.profilePic,
          width: MediaQuery.of(context).size.width * .105,
          height: MediaQuery.of(context).size.width * .105,
        ),
        const SizedBox(width: Styles.defaultSpacing),
        Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Styles.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: Styles.defaultSpacing),
        Text(
          widget._post.createdAt,
          style: const TextStyle(color: Color.fromARGB(184, 36, 36, 36)),
        ),
      ],
    );
  }
}
