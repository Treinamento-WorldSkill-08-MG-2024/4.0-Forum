import 'package:application/design/styles.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                    const Text(
                      "Carlos Anãonelli",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Styles.black,
                          fontSize: 16),
                    ),
                    const SizedBox(width: Styles.defaultSpacing),
                    const Text(
                      "14h",
                      style: TextStyle(color: Color.fromARGB(184, 36, 36, 36)),
                    ),
                  ],
                ),
                PopupMenuButton(
                  itemBuilder: (_) =>
                      [const PopupMenuItem(child: Text("item"))],
                )
              ],
            ),

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
