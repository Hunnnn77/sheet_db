import "package:flutter/material.dart";

T _getProvider<T extends InheritedWidget>(BuildContext context) {
  final T? provider = context.dependOnInheritedWidgetOfExactType<T>();
  if (provider == null) {
    throw Error();
  }
  return provider;
}

R _looper<R>(Iterable<Object>? li) {
  for (final Object c in li ?? <Object>[]) {
    if (c.runtimeType == R) {
      return c as R;
    }
  }
  throw Error();
}

enum Notifiers { valueNotifier, changeNotifier }

final class Provider extends InheritedWidget {
  const Provider({
    required super.child,
    Iterable<Object>? children,
    Iterable<ValueNotifier<Object>>? valueNotifiers,
    Iterable<ChangeNotifier>? changeNotifiers,
    super.key,
  })  : _valueNotifiers = valueNotifiers,
        _changeNotifiers = changeNotifiers,
        _children = children;

  final Iterable<ValueNotifier<Object>>? _valueNotifiers;
  final Iterable<ChangeNotifier>? _changeNotifiers;
  final Iterable<Object>? _children;

  static T of<T>(BuildContext context) {
    final Provider provider = _getProvider<Provider>(context);
    return _looper<T>(<Object>[
      ...?provider._valueNotifiers,
      ...?provider._changeNotifiers,
      ...?provider._children,
    ]);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      child != oldWidget.child;
}

final class RepositoryProvider extends InheritedWidget {
  const RepositoryProvider({
    required super.child,
    required Iterable<Object> children,
    super.key,
  }) : _children = children;

  final Iterable<Object> _children;

  static T of<T>(BuildContext context) {
    final RepositoryProvider provider =
        _getProvider<RepositoryProvider>(context);
    return _looper<T>(provider._children);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      child != oldWidget.child;
}

final class ViewModelProvider extends InheritedWidget {
  const ViewModelProvider({
    required super.child,
    required Iterable<Object> children,
    super.key,
  }) : _children = children;

  final Iterable<Object> _children;

  static T of<T>(BuildContext context) {
    final ViewModelProvider provider = _getProvider<ViewModelProvider>(context);
    return _looper<T>(provider._children);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      child != oldWidget.child;
}
