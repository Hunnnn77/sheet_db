part of "home.dart";

class _ListView extends StatelessWidget {
  const _ListView();
  @override
  Widget build(BuildContext context) {
    final ProjectsViewModel projects =
        ViewModelProvider.of<ProjectsViewModel>(context);
    final Routing routing = Provider.of<Routing>(context);

    return StreamBuilder(
      stream: projects.getProject,
      builder:
          (BuildContext context, AsyncSnapshot<Iterable<Project>> snapshot) =>
              snapshot.on(
        pending: () => const CircularProgressIndicator(),
        fail: (({String message, Type type}) ex) =>
            ErrorScreen(Exception(ex.type)),
        success: (Iterable<Project> ok) => ListView.builder(
          itemCount: ok.length,
          itemBuilder: (BuildContext context, int index) {
            final Project project = ok.elementAt(index);
            return Padding(
              padding: screenPadding,
              child: GestureDetector(
                onTap: () => routing.goProject(context, project: project),
                child: _ListItem(
                  index,
                  project: project,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem(this.index, {required this.project});

  final int index;
  final Project project;

  @override
  Widget build(BuildContext context) {
    final ProjectsViewModel projectsViewModel =
        ViewModelProvider.of<ProjectsViewModel>(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 2,
            spreadRadius: 1,
            offset: const Offset(1, 0), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                const Image(
                  image: AssetImage("assets/images/google_drive.png"),
                  width: 40,
                  height: 40,
                  fit: BoxFit.fitWidth,
                ),
                Gap(MediaQuery.of(context).size.width * 0.06),
                Text(project.title),
              ],
            ),
          ),
          IconButton(
            onPressed: () async => await projectsViewModel.delete(index),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
