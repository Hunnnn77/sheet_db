import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:sheet/global/inh.dart";
import "package:sheet/model/project.dart";
import "package:sheet/model/screen.dart";
import "package:sheet/screen/component/global.dart";
import "package:sheet/screen/error/error.dart";
import "package:sheet/screen/scaffolds.dart";
import "package:sheet/vm/screen_vm.dart";
import "package:sheet/vm/vm_base.dart";

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({required this.project, super.key});

  final Project project;

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late List<TextEditingController> textControllers;

  @override
  void initState() {
    super.initState();
    textControllers = List.generate(
      widget.project.data.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (TextEditingController element in textControllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenViewModel screenViewModel =
        ViewModelProvider.of<ScreenViewModel>(context);
    return ProjectScaffold(
      project: widget.project,
      textControllers: textControllers,
      child: StreamBuilder(
        stream: screenViewModel.state$,
        builder: (
          BuildContext context,
          AsyncSnapshot<Result<ScreenState, Exception>> snapshot,
        ) =>
            snapshot.on(
          pending: () => const CircularProgressIndicator(),
          fail: (Err<Exception> e) => ErrorScreen(e.exception),
          success: (ScreenState ok) => GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.project.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontSize: 18),
                    ),
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.04),
                  Expanded(
                    child: ListView(
                      children: List.generate(
                        widget.project.data.length,
                        (int index) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              labelStyle:
                                  Theme.of(context).textTheme.labelSmall,
                              labelText: widget.project.data
                                  .elementAt(index)
                                  .columnValue,
                            ),
                            controller: textControllers.elementAt(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
