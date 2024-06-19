import 'package:application/components/posts/post_header.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final PostModel _postModel;

  const PostCard(this._postModel, {super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(_postModel.authorID),
            const SizedBox(height: Styles.defaultSpacing),

            // ANCHOR - Post Content
            const Text(
              '"What kind of math do you do?" spiel',
              style: TextStyle(fontSize: 18),
            ),
            const Text(
                "as an undegrad math student, I have really enjoyed this deeper view into math that most people don't even get close to gettin close to. Before I took abstract algebra..."),

            const SizedBox(height: Styles.defaultSpacing),

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
                        icon: const Icon(Icons.arrow_circle_up),
                      ),
                      const Text("123", style: TextStyle(color: Styles.black),),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_circle_down),
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
