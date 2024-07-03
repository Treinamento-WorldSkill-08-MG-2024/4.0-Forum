import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StorageOption { profile, publicaton }

class StorageHandler {
  final _supabase = Supabase.instance.client;
  StorageFileApi get _from => _supabase.storage.from('Forum');

  final StorageOption _option;
  StorageHandler(this._option);

  Future<String> uploadFile(File file) async {
    final endpoint = "${_option.name}/${file.uri}";

    if (_option == StorageOption.profile) {
      final removed = await cleanupFiles(
        endpoint
            .replaceAll('///', '/')
            .substring(0, endpoint.lastIndexOf("/") - 2),
      );
      if (removed.isEmpty) {
        if (kDebugMode) {
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

  Future<List<FileObject>> cleanupFiles(String from) async {
    final files = await _from.list(path: from);
    final objects = await _from.remove(
      files.map((file) => "$from/${file.name}").toList(),
    );
    return objects;
  }

  Future loadFile(String filePath) async {
    final Uint8List file = await _from.download('${_option.name}/$filePath');
    return file;
  }
}
