part of "../scaffolds.dart";

class _HomeFAB extends StatefulWidget {
  const _HomeFAB(this.uri);

  final Uri uri;

  @override
  State<_HomeFAB> createState() => _HomeFABState();
}

class _HomeFABState extends State<_HomeFAB> {
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsViewModel projectsViewModel =
        ViewModelProvider.of<ProjectsViewModel>(context);
    final Columns columns = Provider.of<Columns>(context);
    final FieldNotifier fields = Provider.of<FieldNotifier>(context);
    final TimeUtil timeUtil = Provider.of<TimeUtil>(context);

    return BackButtonListener(
      onBackButtonPressed: () {
        titleController.clear();
        _clear(fields, columns);
        context.pop();
        return Future.value(true);
      },
      child: FloatingActionButton(
        onPressed: () async {
          fields.appendField(columns);
          await _showDialog(
            context,
            timeUtil,
            titleController,
            fields,
            projectsViewModel,
            columns,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDialog(
    BuildContext context,
    TimeUtil timeUtil,
    TextEditingController titleController,
    FieldNotifier fields,
    ProjectsViewModel projects,
    Columns columns,
  ) async {
    final ScreenViewModel screenViewModel =
        ViewModelProvider.of<ScreenViewModel>(context);

    late bool isBusy;
    screenViewModel.state$.listen(
      (Result<ScreenState, Exception> state) => switch (state.unwrap()) {
        LoadingState() => isBusy = true,
        _ => isBusy = false,
      },
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              leading: StreamBuilder(
                stream: screenViewModel.state$,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<Result<ScreenState, Exception>> snapshot,
                ) =>
                    snapshot.on(
                  pending: () => const CircularProgressIndicator(),
                  fail: (Err<Exception> err) => ErrorScreen(err.exception),
                  success: (ScreenState ok) => switch (ok) {
                    OkState() => IconButton(
                        onPressed: () {
                          fields.clear();
                          columns.clear();
                          titleController.clear();
                          context.pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    _ => const SizedBox()
                  },
                ),
              ),
              title: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "title?".cap,
                  labelStyle: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.cyan),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    fields.appendField(columns);
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    fields.removeField();
                  },
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (columns.data.toShrink.isEmpty) {
                  _clear(fields, columns);
                  context.pop();
                  return;
                }
                screenViewModel.add(const LoadingEvent());
                if (isBusy) {
                  return;
                }
                await _createSheet(
                  titleController.text.isNotEmpty
                      ? titleController.text
                      : timeUtil.getFormat,
                  projects.sheetRepository,
                  projects,
                  fields,
                  columns,
                ).then((Result<(), Exception> e) {
                  if (e.isErr) {
                    titleController.clear();
                    screenViewModel.add(
                      ErrorEvent(
                        CreationException("_createSheet failure"),
                      ),
                    );
                    return;
                  }
                  screenViewModel.add(const OkEvent());
                  titleController.clear();
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
                });
              },
              child: Builder(
                builder: (BuildContext context) => StreamBuilder(
                  stream: screenViewModel.state$,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Result<ScreenState, Exception>> snapshot,
                  ) =>
                      snapshot.on(
                    pending: () => const CircularProgressIndicator(),
                    fail: (Err<Exception> e) => ErrorScreen(e.exception),
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
            ),
            body: Padding(
              padding: screenPadding,
              child: ListenableBuilder(
                listenable: fields,
                builder: (BuildContext context, Widget? child) => ListView(
                  children: List.generate(
                    fields.fields.length,
                    (int index) => fields.fields[index],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clear(
    FieldNotifier fields,
    Columns columns,
  ) {
    fields.clear();
    columns.clear();
  }

  Future<Result<(), Exception>> _createSheet(
    String sheetTitle,
    SheetRepository sheet,
    ProjectsViewModel projects,
    FieldNotifier fields,
    Columns columns,
  ) async {
    final Iterable<ColumnData> cols = columns.data.toShrink;

    await sheet
        .createSheet(sheetTitle, columnData: cols)
        .then((Result<String, Exception> e) {
      if (e.isErr) {
        logger.e("$e");
        _clear(fields, columns);
        return Err<CreationException>(
          CreationException("sheet.createSheet error"),
        );
      }
      final Project proj =
          Project(id: e.unwrap(), title: sheetTitle, data: cols);
      if (isDev) {
        logger.d("title $proj / columns: $cols");
      }
      projects.append(proj);
      _clear(fields, columns);
    });
    return const Ok<()>(());
  }
}

enum DialogType { file, settings }

class _Dialog extends StatelessWidget {
  const _Dialog({required this.size, required this.dialogType});

  final DialogType dialogType;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final FilePath filePath = Provider.of<FilePath>(context);
    const TextStyle textStyle = TextStyle(fontSize: 14);
    return Dialog(
      child: SizedBox(
        width: size.height * 0.40,
        height: size.height * 0.40,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: switch (dialogType) {
            DialogType.file => _File(
                filePath: filePath,
                textStyle: textStyle,
              ),
            DialogType.settings =>
              _Settings(textStyle: textStyle, filePath: filePath),
          },
        ),
      ),
    );
  }
}

@deprecated
class _File extends StatelessWidget {
  const _File({required this.filePath, required this.textStyle});

  final FilePath filePath;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              FutureBuilder(
                future: FilePath.getPath(DirType.external),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) =>
                        snapshot.on(
                  pending: () => const CircularProgressIndicator(),
                  fail: (({String message, Type type}) ex) =>
                      ErrorScreen(Exception(ex.message)),
                  success: (String ok) => Text(
                    "path: $ok".cap,
                    style: textStyle,
                  ),
                ),
              ),
              const Gap(8),
              Row(
                children: <Widget>[
                  const Text("a.json:"),
                  const Gap(8),
                  FutureBuilder(
                    future: filePath.read(fileKey).toForked,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<Uint8List> snapshot,
                    ) =>
                        snapshot.on(
                      pending: () => const CircularProgressIndicator(),
                      fail: (({String message, Type type}) ex) =>
                          Text(ex.message),
                      success: (Uint8List ok) => ok.isNotEmpty
                          ? Text(
                              utf8.decode(ok).isNotEmpty ? "ok" : "no",
                              style: textStyle,
                            )
                          : Text("empty content", style: textStyle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: Text("close".cap),
            ),
          ),
        ],
      );
}

class _Settings extends StatelessWidget {
  const _Settings({required this.textStyle, required this.filePath});

  final TextStyle textStyle;
  final FilePath filePath;

  @override
  Widget build(BuildContext context) {
    final ProjectsViewModel projectsViewModel =
        ViewModelProvider.of<ProjectsViewModel>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            FutureBuilder(
              future: FilePath.getPath(DirType.external),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
                  snapshot.on(
                pending: () => const CircularProgressIndicator(),
                fail: (({String message, Type type}) ex) => Text("${ex.type}"),
                success: (String ok) => Text(
                  "path: $ok".cap,
                  style: textStyle,
                ),
              ),
            ),
            const Gap(8),
            Row(
              children: <Widget>[
                const Text("a.json:"),
                const Gap(8),
                FutureBuilder(
                  future: filePath.read(fileKey).toForked,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Uint8List> snapshot,
                  ) =>
                      snapshot.on(
                    pending: () => const CircularProgressIndicator(),
                    fail: (({String message, Type type}) ex) =>
                        Text("${ex.type}"),
                    success: (Uint8List ok) => ok.isNotEmpty
                        ? Text(
                            utf8.decode(ok).isNotEmpty ? "ok" : "no",
                            style: textStyle,
                          )
                        : Text("empty content", style: textStyle),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Row(
              children: <Widget>[
                Text("client:".cap, style: textStyle),
                const Gap(8),
                Text(
                  projectsViewModel.sheetRepository.clientIsSome ? "ok" : "no",
                  style: textStyle,
                ),
              ],
            ),
            const Gap(8),
            Row(
              children: <Widget>[
                Text("credential:".cap, style: textStyle),
                const Gap(8),
                Text(
                  projectsViewModel.sheetRepository.credentialIsSome
                      ? "ok"
                      : "no",
                  style: textStyle,
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text("close".cap),
        ),
      ],
    );
  }
}
