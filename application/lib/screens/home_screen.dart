import 'package:application/components/arch_bottom_bar.dart';
import 'package:application/components/posts/post_card.dart';
import 'package:application/components/profile_drawer.dart';
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
  final _publicationHandler = PublicationHandler();
  final _nextPageTrigger = .8;
  final _postPerRequest = 4;

  late final List<PostModel> _posts;
  late final ScrollController _scrollController;
  late Future<List<PostModel>> _postsFuture;
  late bool _isLastPage;
  late int _pageNumber;

  var _isLoading = true;

  @override
  void initState() {
    _scrollController = ScrollController();
    _posts = List<PostModel>.empty(growable: true);

    _isLastPage = true;
    _pageNumber = 0;

    _loadPosts();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPosts() {
    _isLoading = true;

    _postsFuture = _publicationHandler.loadFeed(_pageNumber);
    _postsFuture
        .then((posts) => setState(() {
              _isLastPage = posts.length < _postPerRequest;
              _pageNumber += 1;

              _posts.addAll(posts);

              _isLoading = false;
            }))
        .catchError((error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      final nextPageTriggerInPixels =
          _nextPageTrigger * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > nextPageTriggerInPixels &&
          !_isLoading) {
        _loadPosts();
      }
    });

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
                Builder(builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.person_2_outlined),
                  );
                })
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [_feed()],
        ),
      ),
      drawer: const ProfileDrawer(),
      bottomNavigationBar: const ArchBottomBar(),
    );
  }

  Widget _feed() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_isLastPage ? 0 : 1),
        itemBuilder: (_, index) {
          if (index == _posts.length) {
            return const Center(
              child: Text(
                  "Não encontramos mais posts ou ainda estão sendo carregados"),
            );
          }

          return PostCard(_posts[index]);
        },
      ),
    );
  }
}
