import 'package:application/components/buttons/like_button.dart';
import 'package:application/components/carousel.dart';
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

                // ANCHOR - Title
                if (Navigator.of(context).canPop())
                  Text(
                    _post.title,
                    style: const TextStyle(fontSize: 18),
                  )
                else
                  SizedBox(
                    child: Text(
                      _post.title,
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: Styles.defaultSpacing),

            Builder(builder: (_) {
              imageWidget(final url) =>
                  Image.network(StorageHandler.fmtImageUrl(url));
              final contentWidget = Text(
                _post.content,
                style: const TextStyle(fontSize: 16),
              );

              if (!Navigator.of(context).canPop()) {
                if (_post.images.isNotEmpty) {
                  return Carousel(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .6,
                    viewportFraction: 1,
                    images: _post.images,
                    imageBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: imageWidget(
                        _post.images[index].toString(),
                      ),
                    ),
                  );
                }

                return contentWidget;
              }

              if (_post.images.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Carousel(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .6,
                      viewportFraction: 1,
                      images: _post.images,
                      imageBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: imageWidget(
                          _post.images[index].toString(),
                        ),
                      ),
                    ),
                    contentWidget,
                  ],
                );
              }

              return contentWidget;
            }),

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
                  onPressed: () {
                    // TODO - Share using deep links
                    // LINK - https://developer.android.com/training/app-links?hl=pt-br
                  },
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
