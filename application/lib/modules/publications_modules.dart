import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

sealed class IPublicationModel {
  late final String uriKeyword;
  final int? id;
  final String content;
  final int likesCount;
  final int commentsCount;

  IPublicationModel(this.id, this.content, this.likesCount, this.commentsCount);
  Map<String, dynamic> toJson();
}

class PostModel extends IPublicationModel {
  @override
  get uriKeyword => "post";

  final int? _id;
  final String _content;
  final String title;
  final bool published;
  final String createdAt;
  final int authorID;
  final List<String>? images;

  PostModel(
    this._id,
    this._content,
    this.title,
    this.published,
    this.createdAt,
    this.authorID,
    this.images, {
    int commentsCount = 0,
    int likesCount = 0,
  }) : super(_id, _content, likesCount, commentsCount);

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'content': String content,
        'title': String title,
        'published': bool published,
        'created-at': String createdAt,
        'author-id': int authorID,
        'comments-count': int commentsCount,
        'likes-count': int likesCount,
        'images': List<String>? images,
      } =>
        PostModel(id, content, title, published, createdAt, authorID, images,
            commentsCount: commentsCount, likesCount: likesCount),
      _ => throw const FormatException("Failed to convert json to post model")
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': title,
      'published': published,
      'created-at': createdAt,
      'author-id': authorID,
      'content': _content,
      'images': images,
    };
  }
}

class CommentModel extends IPublicationModel {
  @override
  get uriKeyword => "comment";

  final int? _id;
  final String _content;
  final bool published;
  final int authorID;
  final int? postID;
  final int? commentID;

  CommentModel(
    this._id,
    this._content,
    this.published,
    this.authorID,
    this.postID,
    this.commentID, {
    int likesCount = 0,
    int commentsCount = 0,
  }) : super(_id, _content, likesCount, commentsCount);

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'content': String content,
        'published': bool published,
        'author-id': int authorID,
        'post-id': int? postID,
        'comment-id': int? commentID,
        'likes-count': int likesCount,
        'comments-count': int commentsCount,
      } =>
        CommentModel(id, content, published, authorID, postID, commentID,
            likesCount: likesCount, commentsCount: commentsCount),
      _ => throw const FormatException("Failed to convert json to post model")
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'content': _content,
      'published': published,
      'author-id': authorID,
      'post-id': postID,
      'comment-id': commentID,
    };
  }
}

class PublicationHandler {
  static const _kBaseURL = "http://10.0.2.2:1323";
  static const _headers = {'Content-Type': "application/json"};

  final http.Client _client;
  final IPublicationModel? _publication;

  PublicationHandler({IPublicationModel? publication})
      : _client = http.Client(),
        _publication = publication;

  factory PublicationHandler.given(IPublicationModel publication) {
    return PublicationHandler(publication: publication);
  }

  Future<List<PostModel>> loadFeed(int page) async {
    final response = await http.Client().get(
      Uri.parse("$_kBaseURL/feed/$page"),
      headers: _headers,
    );

    final bodyData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print(bodyData);
      }

      throw Exception(bodyData);
    }
    assert(bodyData.containsKey("message"));
    final data = bodyData['message'] as List<dynamic>;
    print(data);
    return data.map((item) => PostModel.fromJson(item)).toList();
  }

  Future<List<CommentModel>> loadCommentReplies(int commentID) async {
    final response = await _client.get(
      Uri.parse("$_kBaseURL/comment/$commentID/replies"),
      headers: _headers,
    );

    if (response.statusCode == HttpStatus.noContent) {
      return [];
    }

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"));

    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(bodyData['message']);
      }

      throw Exception(bodyData['message']);
    }

    final data = bodyData['message'] as List<dynamic>;
    return data.map((item) => CommentModel.fromJson(item)).toList();
  }

  Future<List<CommentModel>> loadPostComments(int postID) async {
    final response = await _client.get(
      Uri.parse("$_kBaseURL/post/comments/$postID"),
      headers: _headers,
    );

    if (response.statusCode == HttpStatus.noContent) {
      return [];
    }

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"));

    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(bodyData['message']);
      }

      throw Exception(bodyData['message']);
    }

    final data = bodyData['message'] as List<dynamic>;
    return data.map((item) => CommentModel.fromJson(item)).toList();
  }

  Future<int> likePost(int currentUserID) async {
    assert(_publication != null, "Publication field must be not equal to null");

    final response = await _client.post(
      Uri.parse("$_kBaseURL/${_publication!.uriKeyword}/like"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user-id': currentUserID,
        'post-id': _publication is PostModel ? _publication.id : null,
        'comment-id': _publication is CommentModel ? _publication.id : null,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    assert(data.containsKey("message"));
    return data['message'] as int;
  }

  Future<bool> removeLikePost(int likeId) async {
    final response = await _client.delete(
      Uri.parse("$_kBaseURL/like/$likeId"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != HttpStatus.noContent) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    return true;
  }

  Future<int> isPostLiked(int currentUserId) async {
    assert(_publication != null, "Publication field must be not equal to null");

    final response = await _client.get(
      Uri.parse(
        "$_kBaseURL/${_publication!.uriKeyword}/liked/${_publication.id!}/$currentUserId",
      ),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    assert(data.containsKey("message"));

    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    return data['message'] as int;
  }

  Future<bool> newPublication(int currentUserID) async {
    assert(_publication != null, "Publication field must be not equal to null");

    final response = await _client.post(
      Uri.parse("$_kBaseURL/${_publication!.uriKeyword}"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_publication.toJson()),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != HttpStatus.created) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    return data['message'] != null;
  }
}
