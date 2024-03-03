import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audiobook_app/core/constants/app_constants.dart';
import 'package:audiobook_app/core/service/prefs.dart';

import 'file_utilities.dart';
import 'package:dio/dio.dart';

class DownloadManager {
  DownloadManager._();

  static String directoryName = 'audiobooks';

  static Future<void> download(String url, String filename, {required Function(double progress) onProgress}) async {
    try {
      final dio = Dio();

      if (await FileUtils.exists("$directoryName/$filename")) {
        return;
      }

      await FileUtils.createDirectory(directoryName);
      try {
        String downloadDirectory = "${await (FileUtils.getApplicationDocumentsDirectoryPath())}/$directoryName";
        await Directory(downloadDirectory).create(recursive: true);

        final response = await dio.download(
          url,
          '$downloadDirectory/$filename',
          onReceiveProgress: (received, total) {
            onProgress(received / total);
          },
        );

        if (response.statusCode != 200) {
          throw Exception("Download failed: ${response.statusCode}");
        } else {
          Map data = {"id": filename, "path": '$downloadDirectory/$filename'};
          List<String> paths = await Prefs.getStringList(AppConstants.kDownloadedFilePathsKey) ?? [];
          paths = [json.encode(data), ...paths];
          await Prefs.setStringList(AppConstants.kDownloadedFilePathsKey, paths);
        }
      } catch (e) {
        print(e);
        rethrow;
      }
    } catch (e) {
      print('#error $e');
      rethrow;
    }
  }
}
