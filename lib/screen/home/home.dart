import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:sheet/global/inh.dart";
import "package:sheet/model/project.dart";
import "package:sheet/screen/component/global.dart";
import "package:sheet/screen/error/error.dart";
import "package:sheet/screen/error_stream_screen.dart";
import "package:sheet/screen/scaffolds.dart";
import "package:sheet/util/routing.dart";
import "package:sheet/vm/project_vm.dart";
import "package:sheet/vm/vm_base.dart";

part "_home.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeScaffold(
        child: ErrStreamScreen(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: _ListView(),
          ),
        ),
      );
}
