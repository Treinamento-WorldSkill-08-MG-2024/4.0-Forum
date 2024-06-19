import 'package:application/components/arch_bottom_bar.dart';
import 'package:application/components/posts/post_card.dart';
import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<PostModel>> _posts;

  @override
  void initState() {
    _posts = PublicationHandler().loadFeed(0);

    super.initState();
  }

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
      body: SafeArea(
        child: FutureBuilder<List<PostModel>>(
          future: _posts,
          builder: (context, snapshot) {
            // TODO - Screen skeleton
            if (snapshot.hasError) {
              if (kDebugMode) {
                print(snapshot.error);
              }

              return Container();
            }

            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
                  print(snapshot.data![0].authorID);
              return _feed(snapshot.data!);
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
      bottomNavigationBar: const ArchBottomBar(),
    );
  }

  Widget _feed(List<PostModel> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (_, index) => Column(
        children: [PostCard(posts[index])],
      ),
    );
  }
}
