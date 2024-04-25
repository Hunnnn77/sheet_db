import "package:freezed_annotation/freezed_annotation.dart";

part "screen.freezed.dart";

@freezed
sealed class ScreenState with _$ScreenState {
  const factory ScreenState.loadingState() = LoadingState;

  const factory ScreenState.okState() = OkState;
}

@freezed
sealed class ScreenEvent with _$ScreenEvent {
  const factory ScreenEvent.loadingEvent() = LoadingEvent;

  const factory ScreenEvent.errorEvent(Exception e) = ErrorEvent;

  const factory ScreenEvent.okEvent() = OkEvent;
}
