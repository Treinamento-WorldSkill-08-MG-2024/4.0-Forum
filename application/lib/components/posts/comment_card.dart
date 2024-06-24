import 'package:application/components/buttons/like_button.dart';
import 'package:application/components/posts/comment_header.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/screens/new_comment_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  final CommentModel _comment;

  const CommentCard(this._comment, {super.key});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late final Future<List<CommentModel>> _repliesFuture;

  @override
  void initState() {
    print(widget._comment.id);
    _repliesFuture =
        PublicationHandler().loadCommentReplies(widget._comment.id!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommentHeader(widget._comment),
            Text(widget._comment.content),

            //ANCHOR - Comment Actions
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: Styles.defaultSpacing,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NewCommentScreen(
                          originCommentContent: widget._comment.content,
                          originCommentAuthor: "Placeholder nome autor",
                        ),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.reply, color: Styles.orange),
                        SizedBox(width: Styles.defaultSpacing),
                        Text(
                          "Responder",
                          style: TextStyle(color: Styles.black),
                        )
                      ],
                    ),
                  ),
                  LikeButton(widget._comment),
                ],
              ),
            ),

            // ANCHOR - replies
            FutureBuilder(
              future: _repliesFuture,
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  if (kDebugMode) {
                    print(snapshot.error!);
                  }

                  return Text("Houve um erro");
                }

                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return _loadReplies(snapshot.data!);
                }

                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadReplies(List<CommentModel> comments) {
    return ListView.builder(
      itemCount: comments.length,
      shrinkWrap: true,
      itemBuilder: (_, index) => CommentCard(comments[index]),
    );
  }
}
