import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:sheet/extension/shrink_fields.dart";
import "package:sheet/extension/strings.dart";
import "package:sheet/global/configs.dart";
import "package:sheet/global/errs.dart";
import "package:sheet/global/inh.dart";
import "package:sheet/global/keys.dart";
import "package:sheet/model/field.dart";
import "package:sheet/model/project.dart";
import "package:sheet/model/screen.dart";
import "package:sheet/repository/impl_sheet.dart";
import "package:sheet/screen/component/global.dart";
import "package:sheet/screen/error/error.dart";
import "package:sheet/util/logger.dart";
import "package:sheet/util/path_provider.dart";
import "package:sheet/util/routing.dart";
import "package:sheet/util/time.dart";
import "package:sheet/vm/notifiers/fields_notifier.dart";
import "package:sheet/vm/project_vm.dart";
import "package:sheet/vm/screen_vm.dart";
import "package:sheet/vm/vm_base.dart";

part "component/_home_fab.dart";
part "component/_project_fab.dart";

class HomeScaffold extends StatelessWidget {
  const HomeScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Routing routing = Provider.of<Routing>(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton.outlined(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) => _Dialog(
                  size: size,
                  dialogType: DialogType.settings,
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        centerTitle: true,
        title: const Text("SheetDB"),
      ),
      floatingActionButton: _HomeFAB(routing.getCurrentPath(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: isDev ? _BottomNavigation(child: child) : child,
    );
  }
}

class ProjectScaffold extends StatelessWidget {
  const ProjectScaffold({
    required this.child,
    required this.project,
    required this.textControllers,
    super.key,
  });

  final Widget child;
  final Project project;
  final List<TextEditingController> textControllers;

  @override
  Widget build(BuildContext context) {
    final ScreenViewModel screenViewModel =
        ViewModelProvider.of<ScreenViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        leading: StreamBuilder(
          stream: screenViewModel.state$,
          builder: (
            BuildContext context,
            AsyncSnapshot<Result<ScreenState, Exception>> snapshot,
          ) =>
              snapshot.on(
            pending: () => const CircularProgressIndicator(),
            fail: (Err<Exception> e) => ErrorScreen(e.exception),
            success: (ScreenState ok) => switch (ok) {
              OkState() => IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              _ => const SizedBox(),
            },
          ),
        ),
      ),
      floatingActionButton:
          _ProjectFAB(project: project, textControllers: textControllers),
      body: child,
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FilePath filePath = Provider.of<FilePath>(context);
    final ProjectsViewModel projectsViewModel =
        ViewModelProvider.of<ProjectsViewModel>(context);

    return Stack(
      children: <Widget>[
        child,
        Positioned(
          bottom: 0,
          width: size.width,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: const Offset(1, 2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: <Widget>[
                  IconButton.outlined(
                    onPressed: () async {
                      final String json =
                          await rootBundle.loadString("assets/$fileKey");
                      await filePath.write(
                        fileKey,
                        textBytes: utf8.encode(json),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                  IconButton.outlined(
                    onPressed: () async {
                      logger.d(await FilePath.externalPath);
                      logger.d("from file: ${await filePath.read(fileKey)}");
                      logger.d(
                        "from localStorage: ${projectsViewModel.sheetRepository.localStorage.getJson(jsonKey)}",
                      );
                    },
                    icon: const Icon(Icons.print),
                  ),
                  IconButton.outlined(
                    onPressed: () async {
                      await Future.wait(<Future<void>>[
                        projectsViewModel.sheetRepository.localStorage
                            .deleteAll(),
                        filePath.delete("a.json"),
                      ]);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
