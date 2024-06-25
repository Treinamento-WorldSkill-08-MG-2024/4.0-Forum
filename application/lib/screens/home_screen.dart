import 'package:application/components/arch_bottom_bar.dart';
import 'package:application/components/home_app_bar.dart';
import 'package:application/components/posts/post_card.dart';
import 'package:application/components/profile_drawer.dart';
import 'package:application/modules/auth_modules.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/screens/post_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Object? currentUser;
  const HomeScreen({super.key, this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _publicationHandler = PublicationHandler();
  final _nextPageTrigger = .8;
  final _postPerRequest = 4;

  late final ScrollController _scrollController;
  late List<PostModel> _posts;
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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO - Make new post appear on top
    _posts = List<PostModel>.empty(growable: true);
    _loadPosts();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPosts() {
    print("LOAD POST");
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
      appBar: const HomeAppBar(),
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
                "Não encontramos mais posts ou ainda estão sendo carregados",
              ),
            );
          }

          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PostScreen(_posts[index]),
            )),
            child: PostCard(_posts[index]),
          );
        },
      ),
    );
  }
}
