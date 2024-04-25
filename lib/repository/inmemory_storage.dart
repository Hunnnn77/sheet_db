import "package:gsheets/gsheets.dart";
import "package:sheet/global/errs.dart";
import "package:sheet/global/keys.dart";
import "package:sheet/model/field.dart";
import "package:sheet/model/project.dart";
import "package:sheet/repository/impl_sheet.dart";
import "package:sheet/vm/vm_base.dart";

final class InMemory {
  InMemory._({required this.sheetRepository});

  factory InMemory.getInstance(SheetRepository sheetRepository) =>
      InMemory._(sheetRepository: sheetRepository);

  late Iterable<Spreadsheet> sheets;
  late List<Project> projects;
  final SheetRepository sheetRepository;

  Future<Result<(), Exception>> load() async {
    try {
      final List<String> sheetIds =
          sheetRepository.localStorage.getIds(sheetsKey);
      sheets = await Future.wait(
        sheetIds.map(
          (String e) async =>
              (await sheetRepository.getSpreadSheet(e)).unwrap(),
        ),
      );

      projects = await Future.wait(
        sheets.map((Spreadsheet sh) async {
          final Worksheet? ws = sh.worksheetByTitle("Sheet1");
          if (ws == null) {
            throw NullValueException("ws is null");
          }
          final List<String> columns = await ws.values.row(1);
          return Project(
            id: sh.id,
            title: sh.data.properties.title ?? "unknown",
            data: columns.map((String e) {
              final [String field, String type] = e.split("_");
              return ColumnData(
                index: columns.indexOf(e),
                type: type,
                columnValue: field,
              );
            }),
          );
        }),
      );
    } on Exception catch (e) {
      return Err<Exception>(e);
    }
    return const Ok<()>(());
  }
}
