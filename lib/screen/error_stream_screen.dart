import "package:flutter/material.dart";
import "package:rxdart/rxdart.dart";
import "package:sheet/global/inh.dart";
import "package:sheet/model/screen.dart";
import "package:sheet/screen/error/error.dart";
import "package:sheet/util/logger.dart";
import "package:sheet/vm/screen_vm.dart";
import "package:sheet/vm/vm_base.dart";

class ErrStreamScreen extends StatelessWidget {
  const ErrStreamScreen({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ScreenViewModel screenViewModel =
        ViewModelProvider.of<ScreenViewModel>(context);
    return StreamBuilder(
      stream: screenViewModel.state$
          .doOnError((Object p0, StackTrace p1) => logger.e("$p0")),
      builder: (
        BuildContext context,
        AsyncSnapshot<Result<ScreenState, Exception>> snapshot,
      ) =>
          snapshot.on(
        pending: () => const CircularProgressIndicator(),
        fail: ErrorScreen.new,
        success: (ScreenState ok) => child,
      ),
    );
  }
}
