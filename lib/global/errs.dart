sealed class E implements Exception {
  E(this.message);

  final String message;
}

final class NullValueException extends E {
  NullValueException(super.message);
}

final class InitException extends E {
  InitException(super.message);
}

final class NoInitializationException extends E {
  NoInitializationException(super.message);
}

final class InmemoryException extends E {
  InmemoryException(super.message);
}

final class CreationException extends E {
  CreationException(super.message);
}

final class FileException extends E {
  FileException(super.message);
}
