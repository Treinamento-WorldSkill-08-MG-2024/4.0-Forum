import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StorageOption { profile, publicaton }

class StorageHandler {
  final _supabase = Supabase.instance.client;
  StorageFileApi get _from => _supabase.storage.from('Forum');

  final StorageOption _option;
  StorageHandler(this._option);

  Future<String> uploadFile(File file, String currentUserId) async {
    final endpoint = "${_option.name}/$currentUserId/${file.uri}";

    if (_option == StorageOption.profile) {
      final removed = await _cleanupFiles(endpoint);
      if (kDebugMode) {
        if (removed.isEmpty) {
          print("Nothing removed");
        }
      }
    }

    final String path = await _from.upload(
      endpoint,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
    if (path.isEmpty) {
      throw Exception("Failed to load image");
    }
    return path;
  }

  Future loadFile(String filePath) async {
    final Uint8List file = await _from.download('${_option.name}/$filePath');
    return file;
  }

  Future<List<FileObject>> _cleanupFiles(String from) async {
    final path =
        from.replaceAll('///', '/').substring(0, from.lastIndexOf("/") - 2);
    final files = await _from.list(path: path);
    final objects = await _from.remove(
      files.map((file) => "$path/${file.name}").toList(),
    );
    return objects;
  }

  static fmtImageUrl(String realtiveUri) {
    return 'https://grewcgxljbxprnaupekv.supabase.co/storage/v1/object/public/$realtiveUri';
  }
}
