import "package:flutter/cupertino.dart";
import "package:go_router/go_router.dart";
import "package:sheet/model/project.dart";
import "package:sheet/vm/vm_base.dart";

final class Routing {
  static Pair<String, String> home = const Pair<String, String>(("home", "/"));
  static Pair<String, String> debug =
      const Pair<String, String>(("debug", "debug"));
  static Pair<String, String> projects =
      const Pair<String, String>(("projects", "projects/:title"));

  Uri getCurrentPath(BuildContext context) =>
      GoRouter.of(context).routeInformationProvider.value.uri;

  String _genQuery(String path, Map<String, dynamic> m) =>
      Uri(path: path, queryParameters: m).toString();

  void goWithQuery(
    BuildContext context, {
    required String path,
    required Map<String, dynamic> m,
  }) =>
      context.go(_genQuery(path, m));

  void goHome(BuildContext context) => context.goNamed(home.left);

  void goProject(BuildContext context, {required Project project}) =>
      context.goNamed(
        projects.left,
        pathParameters: <String, String>{"title": project.title},
        extra: project,
      );
}
