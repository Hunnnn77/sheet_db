import "package:sheet/model/field.dart";

extension Shrinked on List<ColumnData> {
  Iterable<ColumnData> get toShrink {
    final Map<int, ColumnData> m = <int, ColumnData>{};
    for (final ColumnData f in this) {
      final int index = f.index;
      if (!m.containsKey(index)) {
        m[index] = f;
      } else {
        m.update(index, (_) => f);
      }
    }
    return m.values;
  }
}
