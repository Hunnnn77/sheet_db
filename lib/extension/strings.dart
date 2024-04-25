extension Strings on String {
  String toCap(String text) => text[0].toUpperCase() + substring(1);

  String get cap => toCap(this);
}
