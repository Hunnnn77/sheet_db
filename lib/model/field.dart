import "package:freezed_annotation/freezed_annotation.dart";

part "field.freezed.dart";

part "field.g.dart";

@freezed
class ColumnData with _$ColumnData {
  const factory ColumnData({
    required int index,
    required String type,
    required String columnValue,
  }) = _ColumnData;

  factory ColumnData.fromJson(Map<String, Object?> json) =>
      _$ColumnDataFromJson(json);
}
