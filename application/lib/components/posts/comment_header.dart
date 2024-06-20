import 'package:application/design/styles.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommentHeader extends StatefulWidget {
  final CommentModel _comment;
  const CommentHeader(this._comment, {super.key});

  @override
  State<CommentHeader> createState() => _CommentHeaderState();
}

class _CommentHeaderState extends State<CommentHeader> {
  late final Future<Object> _authorFuture;

  @override
  void initState() {
    _authorFuture = UserHandler().getUserData(widget._comment.authorID);

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

  Widget _userInfoRow(Object user) {
    return Row(
      children: [
        CircleAvatar(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: Image.network(
              'https://images.unsplash.com/photo-1712847333364-296afd7ba69a?crop=entropy&cs=srgb&fm=jpg&ixid=M3w0Mzc0NDd8MXwxfGFsbHwxfHx8fHx8Mnx8MTcxODcxMjI1OHw&ixlib=rb-4.0.3&q=85&q=85&fmt=jpg&crop=entropy&cs=tinysrgb&w=450',
              width: 120,
            ),
          ),
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
        const Text(
          "14h",
          style: TextStyle(color: Color.fromARGB(184, 36, 36, 36)),
        ),
      ],
    );
  }
}