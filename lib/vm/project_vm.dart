import "dart:async";

import "package:rxdart/rxdart.dart";
import "package:sheet/model/project.dart";
import "package:sheet/repository/impl_sheet.dart";
import "package:sheet/repository/inmemory_storage.dart";

final class ProjectsViewModel {
  ProjectsViewModel({
    required this.sheetRepository,
    required this.inMemory,
  });

  late BehaviorSubject<List<Project>> projectsController =
      BehaviorSubject<List<Project>>.seeded(inMemory.projects);

  final SheetRepository sheetRepository;
  final InMemory inMemory;

  Stream<List<Project>> get getProject => projectsController.stream;

  void append(Project project) {
    inMemory.projects.add(project);
    projectsController.add(inMemory.projects);
  }

  Future<void> delete(int idx) async {
    await sheetRepository.remove(idx).whenComplete(() {
      inMemory.projects.removeAt(idx);
      projectsController.add(inMemory.projects);
    });
  }

  Future<void> deleteAll() async {
    await sheetRepository.debug().whenComplete(() {
      inMemory.projects.clear();
      projectsController.add(inMemory.projects);
    });
  }
}
