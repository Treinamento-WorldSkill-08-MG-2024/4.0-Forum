import 'package:application/components/buttons/like_button.dart';
import 'package:application/components/posts/post_header.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/modules/storage_module.dart';
import 'package:application/screens/home/post_screen.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final PostModel _post;
  final double padding;

  const PostCard(this._post, {super.key, this.padding = 8.0});

  @override
  Widget build(BuildContext context) {
    print(_post.images);

    return Card(
      elevation: .5,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(_post),

            // ANCHOR - Post Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Styles.defaultSpacing),
                Text(
                  _post.title,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(_post.content),
                const SizedBox(height: Styles.defaultSpacing),
              ],
            ),

            _post.images.isNotEmpty
                ? Column(
                    children: [
                      ListView.builder(
                        itemCount: _post.images.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, index) => Image.network(
                          StorageHandler.fmtImageUrl(
                            _post.images[index].toString(),
                          ),
                        ),
                      )
                    ],
                  )
                : const SizedBox.shrink(),

            // ANCHOR - Post Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LikeButton(_post),
                TextButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      return;
                    }

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PostScreen(_post),
                    ));
                  },
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat, color: Styles.orange),
                        onPressed: () => !Navigator.of(context).canPop()
                            ? Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PostScreen(_post),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: Styles.defaultSpacing),
                      Text(
                        _post.commentsCount.toString(),
                        style: const TextStyle(color: Styles.black),
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Icon(Icons.share, color: Styles.orange),
                      SizedBox(width: Styles.defaultSpacing),
                      Text("", style: TextStyle(color: Styles.black))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
