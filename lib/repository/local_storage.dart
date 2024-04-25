import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";
import "package:sheet/global/errs.dart";
import "package:sheet/global/keys.dart";
import "package:sheet/util/path_provider.dart";
import "package:sheet/vm/vm_base.dart";

final class LocalStorage {
  const LocalStorage._();

  factory LocalStorage.getInstance() => const LocalStorage._();

  static late SharedPreferences sharedPreferences;

  static Future<Result<(), Exception>> initialize() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      return Err<Exception>(
        NoInitializationException("sharedPreferences"),
      );
    }
    return const Ok<()>(());
  }

  Future<Result<(), Exception>> setJson(
    FilePath filePath,
    String sheetKey,
  ) async {
    if (filePath.jsonMap.isNone) {
      return Err<Exception>(NullValueException("filePath.key is none"));
    } else {
      await sharedPreferences.setString(
        sheetKey,
        jsonEncode(filePath.jsonMap.unwrap()),
      );
      return const Ok<()>(());
    }
  }

  Option<String> getJson(String jsonKey) {
    final String? value = sharedPreferences.getString(jsonKey);
    if (value == null) {
      return const None();
    } else {
      return Some<String>(value);
    }
  }

  Future<void> setIds(String key, List<String> ids) async =>
      await sharedPreferences.setStringList(key, ids);

  List<String> getIds(String key) =>
      sharedPreferences.getStringList(key) ?? <String>[];

  Future<void> deleteAll() async {
    await Future.wait(<Future<bool>>[
      sharedPreferences.remove(jsonKey),
      sharedPreferences.remove(sheetsKey),
    ]);
  }
}
