import 'package:application/components/profile_pic.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        PopupMenuButton(
          itemBuilder: (_) => [const PopupMenuItem(child: Text("item"))],
        )
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
