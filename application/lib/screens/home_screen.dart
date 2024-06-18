import 'package:application/components/arch_bottom_bar.dart';
import 'package:application/components/post_card.dart';
import 'package:application/design/styles.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const Border.symmetric(
          horizontal: BorderSide(color: Color.fromARGB(75, 36, 36, 36)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.stacked_bar_chart),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                const SizedBox(width: Styles.defaultSpacing),
                const Icon(Icons.person_2_outlined)
              ],
            ),
          )
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            PostCard(),
            PostCard(),
          ],
        ),
      ),
      bottomNavigationBar: const ArchBottomBar(),
    );
  }
}
