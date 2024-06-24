import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final IPublicationModel _publication;

  const LikeButton(this._publication, {super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _isLiked;

  late int _likeId;
  late int _likeCount;

  @override
  void initState() {
    // TODO - Add current user
    PublicationHandler()
        .isPostLiked(widget._publication, 2)
        .then(
          (val) => setState(() {
            _isLiked = val != -1;
            _likeId = val;
          }),
        )
        .catchError((error) => print('error'));

    _isLiked = false;
    _likeCount = widget._publication.likesCount;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          IconButton(
            onPressed: _like,
            icon: Icon(
              !_isLiked ? Icons.star_outline_outlined : Icons.star,
              color: Styles.orange,
              size: 28,
            ),
          ),
          Text(
            _likeCount.toString(),
            style: const TextStyle(color: Styles.black),
          ),
        ],
      ),
    );
  }

  void _like() async {
    if (!_isLiked) {
      final likeId =
          await PublicationHandler().likePost(widget._publication, 2);

      setState(() {
        _likeId = likeId;
        _isLiked = true;
        _likeCount++;
      });

      return;
    }

    final ok = await PublicationHandler().removeLikePost(_likeId);

    if (ok) {
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    }
  }
}
