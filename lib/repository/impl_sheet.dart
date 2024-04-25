import "dart:convert";

import "package:gsheets/gsheets.dart";
import "package:sheet/global/configs.dart";
import "package:sheet/global/errs.dart";
import "package:sheet/global/keys.dart";
import "package:sheet/model/field.dart";
import "package:sheet/repository/local_storage.dart";
import "package:sheet/util/logger.dart";
import "package:sheet/vm/vm_base.dart";

// Client(with credential) -> SpreadSheet(Document with url, id, title ...) > Many WorkingSheets(at bottom, has title)
final class SheetRepository {
  SheetRepository._({required this.localStorage});

  factory SheetRepository.getInstance(LocalStorage localStorage) =>
      SheetRepository._(localStorage: localStorage);

  late List<String> sheetIds = localStorage.getIds(sheetsKey);
  final List<String> contacts = <String>["k01084758975dev@gmail.com"];
  static late Option<GSheets> _client;
  static late Option<Map<String, dynamic>> _credential;
  final LocalStorage localStorage;

  bool get clientIsSome => _client.isSome;

  bool get credentialIsSome => _credential.isSome;

  static Future<Result<(), Exception>> readJson(Option<String> jsonKey) async {
    String key;
    if (jsonKey.isNone) {
      key = "";
    } else {
      key = jsonKey.unwrap();
    }
    if (isDev) {
      logger.d(key);
    }
    if (key.isEmpty) {
      _credential = const None();
    } else {
      _credential = Some(jsonDecode(key));
    }
    if (_credential.isSome) {
      _client = Some(GSheets(_credential.unwrap()));
    } else {
      _client = const None();
    }
    return const Ok<()>(());
  }

  static Future<Result<String, Exception>> get(String key) async {
    if (_credential.isNone) {
      return Err<NoInitializationException>(
        NoInitializationException("not initialized credential"),
      );
    }
    if (_credential.unwrap().containsKey(key)) {
      return Ok<String>(_credential.unwrap()[key]);
    }
    return Err<NoInitializationException>(
      NoInitializationException("not found key"),
    );
  }

  //ExistingOne -> get ss -> get ws
  Future<Option<Spreadsheet>> _createSpreadSheet(String title) async {
    if (_client.isNone) {
      return const None();
    }
    final Spreadsheet s = await _client.unwrap().createSpreadsheet(title);
    return Some<Spreadsheet>(s);
  }

  Future<Option<Spreadsheet>> getSpreadSheet(
    String spreadSheetId, {
    bool create = false,
  }) async {
    if (_client.isNone) {
      return const None();
    }
    final Spreadsheet ss = await _client.unwrap().spreadsheet(spreadSheetId);
    if (create) {
      for (final String c in contacts) {
        await ss
            .share(c)
            .then((Permission value) => logger.d("${value.id} ${value.email}"));
      }
    }
    return Some(ss);
  }

  Future<Worksheet> _getWorkingSheet(
    Spreadsheet ss, [
    String fallbackTitle = "FallbackTitle",
  ]) async {
    final Worksheet ws =
        ss.worksheetByTitle("Sheet1") ?? await ss.addWorksheet(fallbackTitle);
    return ws;
  }

  Future<Result<(), Exception>> appendContents(
    String sheetId, {
    required Iterable<Pair<String, String>> pairs,
    int rowPosition = 2,
  }) async {
    try {
      final Option<Spreadsheet> ss = await getSpreadSheet(sheetId);
      if (ss.isNone) {
        return Err<NullValueException>(
          NullValueException("spread sheet(ss) is null"),
        );
      }
      final Worksheet ws = await _getWorkingSheet(ss.unwrap());
      final List<String> data =
          pairs.map((Pair<String, String> e) => e.right).toList();
      await ws.values.appendRow(data).whenComplete(() {
        if (isDev) {
          logger.d("size: ${pairs.length}, data: $data}");
        }
      });
    } on Exception catch (e) {
      return Err<Exception>(e);
    }
    return const Ok<()>(());
  }

  //impl
  Future<Result<String, Exception>> createSheet(
    String sheetTitle, {
    required Iterable<ColumnData> columnData,
    String fbTitle = "FallbackSheet",
    int rowPosition = 1, //row starts from 1
  }) async {
    logger.w("Creating");
    columnData.toList().sort((ColumnData a, ColumnData b) => a.index - b.index);
    late Option<Spreadsheet> ss;

    try {
      ss = await _createSpreadSheet(sheetTitle);

      if (ss.isNone) {
        return Err<NullValueException>(
          NullValueException("sheet is none"),
        );
      } else {
        if (isDev) {
          logger.d("ss:${ss.unwrap().id}");
        }
        sheetIds.add(ss.unwrap().id);
        ss = await getSpreadSheet(ss.unwrap().id, create: true);
        if (ss.isNone) {
          return Err<NullValueException>(
            NullValueException("spread sheet(ss) is null"),
          );
        } else {
          final Worksheet ws = await _getWorkingSheet(ss.unwrap());
          await ws.values.insertRow(
            rowPosition,
            columnData
                .map((ColumnData e) => "${e.columnValue}_${e.type}")
                .toList(),
          );
          if (isDev) {
            logger.d(
              "ws:$ws ${columnData.map((ColumnData e) => "${e.columnValue}_${e.type}")}",
            );
          }
          await localStorage.setIds(sheetsKey, sheetIds).whenComplete(() {
            if (isDev) {
              logger.d(
                "title:$sheetTitle\nurl:${ss.unwrap().url}\ncols:${ws.values.row(rowPosition)}",
              );
            }
          });
        }
      }
    } on Exception catch (e) {
      return Err<Exception>(e);
    }
    return Ok<String>(ss.unwrap().id);
  }

  //Will be Consumed at ViewModel -> _Appender()
  Future<void> remove(int index) async {
    sheetIds.removeAt(index);
    await localStorage.setIds(sheetsKey, sheetIds);
  }

  Future<void> debug() async =>
      await localStorage.deleteAll().whenComplete(() => sheetIds.clear());
}
