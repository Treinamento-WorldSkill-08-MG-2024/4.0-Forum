import 'package:application/components/posts/post_header.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/screens/post_screen.dart';
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
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PostScreen(_post),
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Styles.defaultSpacing),
                  Text(
                    _post.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Text(
                      "as an undegrad math student, I have really enjoyed this deeper view into math that most people don't even get close to gettin close to. Before I took abstract algebra..."),
                  const SizedBox(height: Styles.defaultSpacing),
                ],
              ),
            ),

            // ANCHOR - Post Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                TextButton(
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Icon(Icons.chat, color: Styles.orange),
                      SizedBox(width: Styles.defaultSpacing),
                      Text(
                        "155 Comentários",
                        style: TextStyle(color: Styles.black),
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
                      Text("69", style: TextStyle(color: Styles.black))
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
