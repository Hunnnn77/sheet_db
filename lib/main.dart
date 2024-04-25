import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:sheet/global/configs.dart";
import "package:sheet/global/errs.dart";
import "package:sheet/global/inh.dart";
import "package:sheet/global/keys.dart";
import "package:sheet/model/project.dart";
import "package:sheet/repository/impl_sheet.dart";
import "package:sheet/repository/inmemory_storage.dart";
import "package:sheet/repository/local_storage.dart";
import "package:sheet/screen/error/error.dart";
import "package:sheet/screen/home/home.dart";
import "package:sheet/screen/project/project.dart";
import "package:sheet/util/path_provider.dart";
import "package:sheet/util/routing.dart";
import "package:sheet/util/time.dart";
import "package:sheet/vm/notifiers/fields_notifier.dart";
import "package:sheet/vm/project_vm.dart";
import "package:sheet/vm/screen_vm.dart";
import "package:sheet/vm/vm_base.dart";
import "package:timezone/data/latest.dart" as tz;

part "./_main.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  final LocalStorage localStorage = LocalStorage.getInstance();
  final [FilePath filePath as FilePath, _] =
      await Future.wait(<Future<Object?>>[
    FilePath.getInstance(DirType.external, fileKey),
    LocalStorage.initialize(),
  ]);

  final SheetRepository sheetRepository =
      SheetRepository.getInstance(localStorage);
  final InMemory inMemory = InMemory.getInstance(sheetRepository);
  final Option<String> keyInLocalStorage = localStorage.getJson(jsonKey);

  if (filePath.jsonMap.isSome && keyInLocalStorage.isNone) {
    await localStorage.setJson(filePath, jsonKey);
  }
  Connectivity()
      .onConnectivityChanged
      .listen((List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      try {
        await SheetRepository.readJson(keyInLocalStorage)
            .then((Result<(), Exception> e) {
          if (e.isErr) {
            runApp(
              ErrorScreen(InitException("initialization error $e")),
            );
          } else {
            inMemory.load().then((Result<(), Exception> err) {
              if (err.isErr) {
                runApp(
                  ErrorScreen(InitException("inmemory error")),
                );
              } else {
                runApp(
                  _Providers(
                    inMemory: inMemory,
                    sheetRepository: sheetRepository,
                    filePath: filePath,
                    child: const _MyApp(),
                  ),
                );
              }
            });
          }
        });
      } on Exception catch (e) {
        runApp(ErrorScreen(e));
      }
    } else {
      runApp(
        ErrorScreen(InitException("please connect wifi or lte")),
      );
    }
  });
}
