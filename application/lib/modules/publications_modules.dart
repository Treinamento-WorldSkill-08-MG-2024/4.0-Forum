import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PostModel {
  final int? id;
  final String title;
  final bool published;
  final String createdAt;
  final int authorID;

  PostModel(this.id, this.title, this.published, this.createdAt, this.authorID);
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'title': String title,
        'published': bool published,
        'created-at': String createdAt,
        'author-id': int authorID,
      } =>
        PostModel(id, title, published, createdAt, authorID),
      _ => throw const FormatException("Failed to convert json to post model")
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'published': published,
      'createdAt': createdAt,
      'authorID': authorID,
    };
  }
}

class CommentModel {
  final int? id;
  final String content;
  final bool published;
  final int authorID;
  final int? postID;
  final int? commentID;

  CommentModel(this.id, this.content, this.published, this.authorID, this.postID, this.commentID);
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'content': String content,
        'published': bool published,
        'author-id': int authorID,
        'post-id': int? postID,
      } =>
        CommentModel(id, content, published, authorID, postID, null),
      _ => throw const FormatException("Failed to convert json to post model")
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content':  content,
      'published':  published,
      'author-id': authorID,
      'post-id':  postID,
      'comment-id':  commentID,
    };
  }
}

class PublicationHandler {
  static const _kBaseURL = "http://10.0.2.2:1323";
  static const _headers = {'Content-Type': "application/json"};

  Future<List<PostModel>> loadFeed(int page) async {
    final response = await http.Client().get(
      Uri.parse("$_kBaseURL/feed/$page"),
      headers: _headers,
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"), "Response does not contain message key");

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print(bodyData['message']);
      }

      throw Exception(bodyData['message']);
    }

    final data = bodyData['message'] as List<dynamic>;
    return data.map((item) => PostModel.fromJson(item)).toList();
  }

  Future<List<CommentModel>> loadPostComments(int postID) async {
    final response = await http.Client().get(
      Uri.parse("$_kBaseURL/post/comments/$postID"), 
      headers: _headers,
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"), "Response does not contain message key");

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print(bodyData['message']);
      }

      throw Exception(bodyData['message']);
    }

    final data = bodyData['message'] as List<dynamic>;
    return data.map((item) => CommentModel.fromJson(item)).toList();
  }
}
