sealed class E {
  E(this.message);

  final String message;
}

final class NullValueException extends E implements Exception {
  NullValueException(super.message);
}

final class InitException extends E implements Exception {
  InitException(super.message);
}

final class NoInitializationException extends E implements Exception {
  NoInitializationException(super.message);
}

final class InmemoryException extends E implements Exception {
  InmemoryException(super.message);
}

final class CreationException extends E implements Exception {
  CreationException(super.message);
}

final class FileException extends E implements Exception {
  FileException(super.message);
}
