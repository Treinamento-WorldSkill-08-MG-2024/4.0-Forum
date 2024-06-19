import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PostModel {
  final String title;
  final bool published;
  final String createdAt;
  final int authorID;

  PostModel(this.title, this.published, this.createdAt, this.authorID);
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'title': String title,
        'published': bool published,
        'created-at': String createdAt,
        'author-id': int authorID,
      } =>
        PostModel(title, published, createdAt, authorID),
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

class PublicationHandler {
  static const _kBaseURL = "http://10.0.2.2:1323";

  Future<List<PostModel>> loadFeed(int page) async {
    final response = await http.Client().get(
      Uri.parse("$_kBaseURL/feed/$page"),
      headers: {'Content-Type': "application/json"},
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"), "Response does not contain message key");

    final data = bodyData['message'] as List<dynamic>;
    if (response.statusCode != 200) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    return data.map((item) => PostModel.fromJson(item)).toList();
  }
}
