import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getApplicationDocumentsDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> getFile(String path) async {
    final fullPath = await _getFullPath(path);
    return File(fullPath);
  }

  static Future<String> _getFullPath(String path) async {
    final documentsPath = await getApplicationDocumentsDirectoryPath();
    return path.startsWith('/') ? path : '$documentsPath/$path';
  }

  static Future<bool> exists(String path) async {
    final file = await getFile(path);
    return await file.exists();
  }

  static Future<void> createDirectory(String directoryName) async {
    final documentsPath = await getApplicationDocumentsDirectoryPath();
    final directory = Directory('$documentsPath/$directoryName');
    await directory.create(recursive: true);
  }

  static Future<void> deleteFile(String path) async {
    final file = await getFile(path);
    await file.delete();
  }
}
