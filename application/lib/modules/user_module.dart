part of './auth_modules.dart';

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? profilePic;

  String? authToken;

  UserModel(this.id, this.name, this.email, this.password,
      {this.profilePic, this.authToken});
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'email': String email,
        'temp-code': String? _,
        'password': String password,
        'profile-pic': String? profilePic,
      } =>
        UserModel(id, name, email, password,
            profilePic: profilePic, authToken: token),
      _ => throw const FormatException("Fail to convert json to user model")
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'profile-pic': profilePic,
    };
  }
}

class UserHandler {
  static const _kBaseURL = "http://10.0.2.2:1323/user";

  Future<UserModel> getUserData(int id) async {
    final response = await http.Client().get(
      Uri.parse("$_kBaseURL/$id"),
      headers: {'Content-Type': 'application/json'},
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

    return UserModel.fromJson(data);
  }

  Future<bool> uploadProfilePic(
    File file,
    int id, {
    required BuildContext context,
  }) async {
    final uploaded =
        await StorageHandler(StorageOption.profile).uploadFile(file, id.toString());

    if (uploaded.isEmpty) {
      throw Exception();
    }

    final response = await http.Client().put(
      Uri.parse(_kBaseURL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id": id, "profile-pic": uploaded}),
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(bodyData);
      }

      throw Exception(bodyData);
    }

    assert(bodyData.containsKey("message"));
    final data = bodyData['message'] as String;
    if (data.isEmpty) {
      throw Exception("new profile pic should not bet empty");
    }

    if (!context.mounted) {
      return false;
    }

    Provider.of<AuthProvider>(context, listen: false).authenticateUser();

    return true;
  }
}
