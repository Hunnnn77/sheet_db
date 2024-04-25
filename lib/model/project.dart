import "package:freezed_annotation/freezed_annotation.dart";

import "package:sheet/model/field.dart";

part "project.freezed.dart";

part "project.g.dart";

@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String title,
    required Iterable<ColumnData> data,
  }) = _Project;

  factory Project.fromJson(Map<String, Object?> json) =>
      _$ProjectFromJson(json);
}
