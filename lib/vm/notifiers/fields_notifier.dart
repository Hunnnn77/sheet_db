import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:sheet/extension/strings.dart";
import "package:sheet/model/field.dart";

final class Columns {
  final List<ColumnData> data = <ColumnData>[];

  void appendData(Set<ColumnData> columnData) {
    final Set<ColumnData> temp = <ColumnData>{};
    temp.addAll(columnData);
    data.add(temp.toList().last);
  }

  void clear() {
    data.clear();
  }
}

final class FieldNotifier extends ChangeNotifier {
  final List<Widget> fields = <Widget>[];

  void appendField(Columns columns) {
    fields.add(
      _Field(
        fieldIndex: fields.length,
        columns: columns,
        key: ValueKey<String>(fields.length.toString()),
      ),
    );
    notifyListeners();
  }

  void removeField() {
    fields.removeLast();
    notifyListeners();
  }

  void clear() {
    fields.clear();
    notifyListeners();
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.columns,
    required this.fieldIndex,
    super.key,
  });

  final int fieldIndex;
  static final List<String> item = <String>[
    "string".cap,
    "number".cap,
    "bool".cap,
  ];
  final Columns columns;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late TextEditingController fieldTextController;
  late ColumnData? fieldData;
  late ValueNotifier<String> option;

  @override
  void initState() {
    option = ValueNotifier<String>(_Field.item.first);
    option.addListener(() {
      if (fieldData case final ColumnData data) {
        widget.columns.appendData(<ColumnData>{
          data.copyWith(
            index: widget.fieldIndex,
            type: option.value,
            columnValue: fieldTextController.text.trim(),
          ),
        });
      }
    });
    fieldTextController = TextEditingController();
    fieldData = ColumnData(index: 0, type: _Field.item.first, columnValue: "");
    fieldTextController.addListener(() {
      if (fieldData case final ColumnData data) {
        if (fieldTextController.text.isNotEmpty) {
          widget.columns.appendData(<ColumnData>{
            data.copyWith(
              index: widget.fieldIndex,
              type: option.value,
              columnValue: fieldTextController.text.trim(),
            ),
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    option.dispose();
    fieldData = null;
    fieldTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            DropdownMenu(
              initialSelection: _Field.item.first,
              onSelected: (String? value) {
                option.value = value!;
              },
              dropdownMenuEntries: _Field.item
                  .map((String e) => DropdownMenuEntry(value: e, label: e))
                  .toList(),
            ),
            const Gap(8),
            Expanded(
              child: TextField(
                controller: fieldTextController,
              ),
            ),
          ],
        ),
      );
}
