import 'package:application/components/home_app_bar.dart';
import 'package:application/components/posts/comment_header.dart';
import 'package:application/components/posts/post_card.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  final PostModel _post;

  const PostScreen(this._post, {super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late final Future<List<CommentModel>> _commentsFuture;

  @override
  void initState() {
    _commentsFuture =
        PublicationHandler().loadPostComments(widget._post.authorID);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCard(
                widget._post,
              ),

              const SizedBox(height: Styles.defaultSpacing * 2),

              // ANCHOR - Comments
              FutureBuilder(
                future: _commentsFuture,
                builder: (_, snapshot) {
                  if (snapshot.hasError) {
                    if (kDebugMode) {
                      print(snapshot.error!);
                    }

                    return const Text("Houve um erro");
                  }

                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return _commentsFeed(snapshot.data!);
                  }

                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _commentsFeed(List<CommentModel> comments) {
    return ListView.builder(
      itemCount: comments.length,
      shrinkWrap: true,
      itemBuilder: (_, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(Styles.defaultSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommentHeader(comments[index]),
              Text(comments[index].content),

              //ANCHOR - Comment Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
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
                  Container(
                    decoration: const BoxDecoration(),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.star_outline_outlined,
                            color: Styles.orange,
                            size: 28,
                          ),
                        ),
                        const Text(
                          "123",
                          style: TextStyle(color: Styles.black),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
