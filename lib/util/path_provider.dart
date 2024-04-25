import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:path_provider/path_provider.dart";
import "package:sheet/global/configs.dart";
import "package:sheet/global/errs.dart";
import "package:sheet/util/logger.dart";
import "package:sheet/vm/vm_base.dart";

enum DirType { external, local }

final class FilePath {
  FilePath._({required this.dirType, required this.jsonMap});

  final DirType dirType;

  //init from getInstance();
  final Option<Map<String, dynamic>> jsonMap;

  static Future<String> get externalPath async =>
      await getExternalStorageDirectory().then(
        (Directory? dir) =>
            dir?.path ??
            "/storage/emulated/0/Android/data/com.example.sheet/files",
      );

  static Future<String> get localPath async =>
      await getApplicationDocumentsDirectory()
          .then((Directory dir) => dir.path);

  static Future<String> getPath(DirType dirType) => Try(
        dirType == DirType.local ? FilePath.localPath : FilePath.externalPath,
      ).toFuture;

  static Future<FilePath> getInstance(DirType dirType, String fileName) async {
    try {
      final Directory path = Directory(await getPath(dirType));

      if (!path.existsSync()) {
        await path.create();
        if (!path.existsSync()) {
          return FilePath._(dirType: dirType, jsonMap: const None());
        }
      }

      final File f = File("${path.path}/$fileName");
      if (!f.existsSync()) {
        return FilePath._(dirType: dirType, jsonMap: const None());
      }

      final Uint8List content = await f.readAsBytes();
      if (content.isEmpty) {
        return FilePath._(dirType: dirType, jsonMap: const None());
      }

      if (isDev) {
        final Map<String, dynamic> json = jsonDecode(utf8.decode(content));
        logger.w("$json ${json.runtimeType}");
      }

      return FilePath._(
        dirType: dirType,
        jsonMap: Some(jsonDecode(utf8.decode(content))),
      );
    } on Exception {
      return FilePath._(dirType: dirType, jsonMap: const None());
    }
  }

  Future<bool> get _isExisting async =>
      Directory(await getPath(dirType)).existsSync();

  Future<Result<Uint8List, Exception>> read(String fileName) async {
    if (!await _isExisting) {
      return Err(FileException("file is not existing"));
    }
    return Ok(
      await Try(
        File("${await getPath(dirType)}/$fileName").readAsBytes(),
      ).toFuture,
    );
  }

  Future<FileSystemEntity> delete(String fileName) async =>
      Try(File("${await getPath(dirType)}/$fileName").delete()).toFuture;

  Future<Result<File, Exception>> write(
    String fileName, {
    required Uint8List textBytes,
  }) async {
    if (!await _isExisting) {
      return Err(FileException("file is not existing"));
    }
    return Ok(
      await Try(
        File("${await getPath(dirType)}/$fileName").writeAsBytes(textBytes),
      ).toFuture,
    );
  }
}
