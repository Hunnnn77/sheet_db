import "package:sheet/model/screen.dart";
import "package:sheet/vm/vm_base.dart";

final class ScreenViewModel extends ViewModel<ScreenState, ScreenEvent> {
  ScreenViewModel() : super(const Ok<OkState>(OkState())) {
    event$.listen(
      (ScreenEvent event) => switch (event) {
        LoadingEvent() => emit(const Ok<LoadingState>(LoadingState())),
        OkEvent() => emit(const Ok<OkState>(OkState())),
        ErrorEvent(e: final Exception ex) => emit(Err<Exception>(ex)),
      },
    );
  }
}
