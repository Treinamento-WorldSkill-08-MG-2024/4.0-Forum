import 'package:application/components/home_app_bar.dart';
import 'package:application/components/posts/comment_card.dart';
import 'package:application/components/posts/post_card.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/screens/new_comment_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  final PostModel _post;

  const PostScreen(this._post, {super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late Future<List<CommentModel>> _commentsFuture;

  @override
  void initState() {
    _commentsFuture = PublicationHandler().loadPostComments(widget._post.id!);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _commentsFuture = PublicationHandler().loadPostComments(widget._post.id!);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostCard(widget._post),
            
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
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("Nenhum comentário encontrado"),
                        );
                      }
            
                      return _commentsFeed(snapshot.data!);
                    }
            
                    return const CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: MediaQuery.of(context).size.height * .08,
        child: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => NewCommentScreen(widget._post),
          )),
          child: const Text("Enviar Comentário"),
        ),
      ),
    );
  }

  Widget _commentsFeed(List<CommentModel> comments) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: comments.length,
      itemBuilder: (_, index) => CommentCard(comments[index]),
    );
  }
}
