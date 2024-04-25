import "dart:async";

import "package:flutter/material.dart";
import "package:rxdart/rxdart.dart";

abstract base class ViewModel<State, Event> {
  ViewModel(Result<State, Exception> state) {
    _state.add(state);
  }

  final BehaviorSubject<Result<State, Exception>> _state =
      BehaviorSubject<Result<State, Exception>>();
  final BehaviorSubject<Event> _event = BehaviorSubject<Event>();

  void emit(Result<State, Exception> state) {
    if (state is Ok) {
      _state.add(state);
    } else if (state is Err) {
      _state.addError(state);
    } else {
      throw Panic(
        state,
        type: Result<State, Exception>,
        message: "unreachable",
      );
    }
  }

  void add(Event event) {
    _event.add(event);
  }

  Future<void> dispose() async {
    await Future.wait(<Future>[
      _event.close(),
      _state.close(),
    ]);
  }

  Stream<Result<State, Exception>> get state$ => _state.stream;

  @protected
  Stream<Event> get event$ => _event.stream;

  @protected
  State get state => _state.value.unwrap();
}

extension type const Option<T>._(T? _) {
  bool get isSome => runtimeType != Null ? true : false;

  bool get isNone => runtimeType == Null ? true : false;

  T unwrap() {
    if (isSome) {
      return _!;
    } else {
      throw Panic(_, type: runtimeType, message: "none");
    }
  }

  T mapNone(T Function() handleNone) => switch (this) {
        Some<T>(_: final T value) => value,
        None() => handleNone(),
      };

  R when<R>({
    required R Function(T ok) some,
    required R Function() none,
  }) =>
      switch (this) {
        Some<T>(_: final T value) => some(value),
        None() => none(),
      };
}

extension type const Some<T>._(T _) implements Option<T> {
  const Some(T _) : this._(_);
}

extension type const None._(Null _) implements Option<Never> {
  const None() : this._(null);
}

sealed class Result<T, E extends Exception> {
  const Result._();

  bool get isOk => this is Ok;

  bool get isErr => this is Err;
}

final class Ok<T> extends Result<T, Never> {
  const Ok(this.value) : super._();

  final T value;

  Type get type => value.runtimeType;

  @override
  String toString() => "Ok{value: $value}";
}

final class Err<E extends Exception> extends Result<Never, E> {
  const Err(this.exception) : super._();

  final E exception;

  Type get type => exception.runtimeType;
  String get message => exception.toString().split(":").last.trim();

  @override
  String toString() => "Err{exception: $exception}";
}

extension AsyncSnapshotMethods<T> on AsyncSnapshot<Result<T, Exception>> {
  Widget on({
    required Widget Function() pending,
    required Widget Function(Err<Exception> err) fail,
    required Widget Function(T ok) success,
  }) {
    if (connectionState == ConnectionState.waiting) {
      return pending();
    }
    if (hasError) {
      return fail(error as Err<Exception>);
    } else {
      return success((data as Ok<T>).value);
    }
  }
}

extension AsnycSnapshotMethodsForPrimitive<T, E extends Exception>
    on AsyncSnapshot<T> {
  Widget on({
    required Widget Function() pending,
    required Widget Function(({Type type, String message}) ex) fail,
    required Widget Function(T ok) success,
  }) {
    if (connectionState == ConnectionState.waiting) {
      return pending();
    }
    if (hasError) {
      return fail(
        (
          type: error.runtimeType,
          message: (error as E).toString().split(":").last.trim()
        ),
      );
    } else {
      return success(data as T);
    }
  }
}

extension ResultMethods<T> on Result<T, Exception> {
  T unwrap() {
    if (this case Ok<T>(value: final T v)) {
      return v;
    } else if (this case Err<Exception>(exception: final Exception e)) {
      throw Panic(this, type: runtimeType, message: e.toString());
    } else {
      throw Panic(this, type: runtimeType, message: "unreachable");
    }
  }

  T mapError(T Function(Exception e) handleErr) => switch (this) {
        Ok<T>() => unwrap(),
        Err<Exception>(exception: final Exception e) => handleErr(e),
        _ => throw Error()
      };

  R when<R>({
    required R Function(T ok) ok,
    required R Function(Exception e) err,
  }) =>
      switch (this) {
        Ok<T>(value: final T value) => ok(value),
        Err<Exception>(exception: final Exception e) => err(e),
        _ => throw Error(),
      };
}

extension ScopedMethods<T> on T {
  R let<R>(R Function(T value) f) => f(this);

  T eq(T value) {
    if (value.runtimeType != runtimeType || value != this) {
      throw BoolPanic(this, value);
    }
    return this;
  }
}

extension type const IntoOption<T>(T? _) {
  Option<T> get wrap {
    if (this case final T value) {
      return Some<T>(value);
    } else {
      return const None();
    }
  }
}

extension type const Try<T, E extends Exception>(Future<T> f) {
  Future<Result<T, E>> get toResult async {
    try {
      return Ok<T>(await f);
    } on Error catch (_) {
      return Err<E>(Exception("error") as E);
    } on Exception catch (e) {
      return Err<E>(e as E);
    }
  }

  Stream<T> get stream$ => toResult.toForked.asStream();

  Future<T> get toFuture async {
    Result<T, E> result;
    try {
      result = Ok<T>(await f);
    } on Error catch (_) {
      result = Err<E>(Exception("error") as E);
    } on Exception catch (e) {
      result = Err<E>(e as E);
    }
    if (result.isErr) {
      return Future<T>.error((result as Err<E>).exception);
    }
    return Future<T>.value(result.unwrap());
  }
}

extension Into<T, E extends Exception> on Future<Result<T, E>> {
  Future<T> get toForked async => await then((Result<T, E> res) {
        if (res.isErr) {
          return Future<T>.error((res as Err<E>).exception);
        }
        return Future<T>.value(res.unwrap());
      });
}

extension type const Pair<T, U>((T, U) tup) {
  T get left => tup.$1;

  U get right => tup.$2;
}

final class Panic implements Exception {
  const Panic(this.value, {required this.type, this.message});
  final Type type;
  final Object? value;
  final String? message;

  @override
  String toString() => "Panic{type: $type, value: $value, message: $message}";
}

final class BoolPanic implements Exception {
  const BoolPanic(this.expected, this.passed);

  final Object? expected;
  final Object? passed;

  @override
  String toString() => "BoolPanic{expected: $expected, passed: $passed}";
}