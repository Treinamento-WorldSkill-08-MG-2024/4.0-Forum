import 'package:application/components/posts/post_card.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/screens/home/post_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PublicationsFeed extends StatefulWidget {
  final double _nextPageTrigger;
  final double _postPerRequest;
  final int? _userID;

  const PublicationsFeed({
    super.key,
    int? userID,
    double nextPageTrigger = .8,
    double postPerRequest = 4,
  })  : _userID = userID,
        _postPerRequest = postPerRequest,
        _nextPageTrigger = nextPageTrigger,
        assert(nextPageTrigger >= .5);

  @override
  State<PublicationsFeed> createState() => _PublicationsFeedState();
}

class _PublicationsFeedState extends State<PublicationsFeed> {
  final _publicationHandler = PublicationHandler();

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
    _posts = List<PostModel>.empty(growable: true);
    _loadPosts();
    super.didChangeDependencies();
  }

  void _loadPosts() {
    print('Calling load posts with ${widget._userID}');
    _isLoading = true;
    _postsFuture = _publicationHandler.loadFeed(
      _pageNumber,
      userID: widget._userID,
    );
    _postsFuture
        .then((posts) => setState(() {
              _isLastPage = posts.length < widget._postPerRequest;
              _pageNumber += 1;

              _posts.addAll(posts);

              _isLoading = false;
            }))
        .catchError((error) {
      if (kDebugMode) {
        print('ERROR: posts future failed.');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      final nextPageTriggerInPixels =
          widget._nextPageTrigger * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > nextPageTriggerInPixels &&
          !_isLoading) {
        _loadPosts();
      }
    });

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
