part of "../scaffolds.dart";

class _ProjectFAB extends StatelessWidget {
  const _ProjectFAB({required this.project, required this.textControllers});

  final Project project;
  final List<TextEditingController> textControllers;

  @override
  Widget build(BuildContext context) {
    final ProjectsViewModel projectsViewModel =
        ViewModelProvider.of<ProjectsViewModel>(context);
    final ScreenViewModel screenViewModel =
        ViewModelProvider.of<ScreenViewModel>(context);

    late bool isBusy;
    screenViewModel.state$.listen(
      (Result<ScreenState, Exception> state) => switch (state.unwrap()) {
        LoadingState() => isBusy = true,
        _ => isBusy = false,
      },
    );

    return BackButtonListener(
      onBackButtonPressed: () {
        for (TextEditingController element in textControllers) {
          element.clear();
        }
        context.pop();
        return Future.value(true);
      },
      child: FloatingActionButton(
        onPressed: () async {
          screenViewModel.add(const LoadingEvent());
          if (isBusy) {
            return;
          }
          await _appendData(context, projectsViewModel)
              .then((Result<(), Exception> e) {
            if (e.isErr) {
              screenViewModel.add(
                ErrorEvent(CreationException("_appendData Failure")),
              );
              return;
            }
            screenViewModel.add(const OkEvent());
            for (TextEditingController element in textControllers) {
              element.clear();
            }
            ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
          });
        },
        child: StreamBuilder(
          stream: screenViewModel.state$,
          builder: (
            BuildContext context,
            AsyncSnapshot<Result<ScreenState, Exception>> snapshot,
          ) =>
              snapshot.on(
            pending: () => const CircularProgressIndicator(),
            fail: (Err<Exception> err) => ErrorScreen(err.exception),
            success: (ScreenState ok) {
              if (ok is LoadingState) {
                return const CircularProgressIndicator();
              } else {
                return const Icon(Icons.add_to_drive);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<Result<(), Exception>> _appendData(
    BuildContext context,
    ProjectsViewModel projectsViewModel,
  ) async {
    final Iterable<Pair<String, String>> pairs =
        Iterable<Pair<String, String>>.generate(
      project.data.length,
      (int index) => Pair<String, String>(
        (
          project.data.elementAt(index).columnValue,
          textControllers.elementAt(index).text
        ),
      ),
    );
    final int posInProj = projectsViewModel.inMemory.projects
        .indexWhere((Project element) => element.id == project.id);
    if (textControllers
        .any((TextEditingController cont) => cont.text.isEmpty)) {
      for (final TextEditingController c in textControllers) {
        c.clear();
      }
      context.pop();
      return Err<NullValueException>(
        NullValueException("some values are missing"),
      );
    }

    if (posInProj == -1) {
      return Err<NullValueException>(
        NullValueException("not found pos in project"),
      );
    } else {
      if (projectsViewModel.sheetRepository.sheetIds
              .elementAtOrNull(posInProj) ==
          null) {
        return Err<NullValueException>(
          NullValueException("not found sheetId"),
        );
      } else {
        await projectsViewModel.sheetRepository.appendContents(
          projectsViewModel.sheetRepository.sheetIds.elementAt(posInProj),
          pairs: pairs,
        );
      }
    }
    return const Ok<()>(());
  }
}
