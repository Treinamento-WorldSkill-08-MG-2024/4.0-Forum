import 'dart:convert';
import 'dart:io';

import 'package:application/modules/storage_module.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

part './user_module.dart';

class UserModelFields {
  static const token = "auth-token";
}

class AuthHandler {
  static const _kBaseURL = "http://10.0.2.2:1323/auth";

  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"));

    final data = bodyData['message'];
    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    assert(data.containsKey("token"));
    assert(data.containsKey("user"));
    final token = data["token"] as String;

    if (!context.mounted) {
      return false;
    }

    return Provider.of<AuthProvider>(context, listen: false)
        .authenticateUser(incomingToken: token);
  }

  Future<UserModel?> isAuthenticated(String token) async {
    final response = await http.Client().post(
      Uri.parse(_kBaseURL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.unauthorized) {
      return null;
    }

    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception("Falha ao autenticar usuário");
    }

    assert((data as Map<String, dynamic>).containsKey("message"));
    return UserModel.fromJson(data["message"]);
  }

  Future<bool> register(UserModel userData) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData.toJson()),
    );

    if (response.statusCode != HttpStatus.created) {
      throw Exception("Falha ao registrar usuário");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data.containsKey('message') && data['message'] != null;
  }

  Future<int?> forgot(String email) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/forgot"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body) as dynamic;
    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(data as String);
      }

      throw Exception("Falha ao enviar email");
    }

    return data['message'];
  }

  Future<bool> validate(int id, String code) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/validate"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id": id, "temp-code": code}),
    );

    if (response.statusCode != HttpStatus.ok) {
      final data = jsonDecode(response.body) as dynamic;
      if (kDebugMode) {
        print(data as String);
      }

      throw Exception("Falha ao validar código");
    }

    return true;
  }

  Future<bool> changePassword(int id, String code, String password) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/changePassword"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id": id, "temp-code": code, "password": password}),
    );

    if (response.statusCode != HttpStatus.ok) {
      final data = jsonDecode(response.body) as dynamic;
      if (kDebugMode) {
        print(data as String);
      }

      throw Exception("Falha a trocar sua senha");
    }

    return true;
  }
}
