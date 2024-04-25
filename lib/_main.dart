part of "./main.dart";

class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    final _Styles styles = Provider.of<_Styles>(context);

    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: isDev ? true : false,
      title: "SheetDB",
      theme: styles.darkTheme,
    );
  }

  GoRouter get _router => GoRouter(
        initialLocation: Routing.home.right,
        debugLogDiagnostics: isDev,
        errorBuilder: (BuildContext context, GoRouterState state) =>
            ErrorScreen(null, goException: state.error),
        routes: <RouteBase>[
          GoRoute(
            name: Routing.home.left,
            path: Routing.home.right,
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                name: Routing.projects.left,
                path: Routing.projects.right,
                builder: (BuildContext context, GoRouterState state) =>
                    ProjectScreen(
                  project: state.extra as Project,
                ),
              ),
            ],
          ),
        ],
      );
}

class _Providers extends StatelessWidget {
  const _Providers({
    required this.child,
    required this.inMemory,
    required this.sheetRepository,
    required this.filePath,
  });

  final InMemory inMemory;
  final SheetRepository sheetRepository;
  final FilePath filePath;
  final Widget child;

  @override
  Widget build(BuildContext context) => Provider(
        changeNotifiers: <ChangeNotifier>[
          FieldNotifier(),
        ],
        children: <Object>[
          _Styles(),
          Columns(),
          TimeUtil(),
          filePath,
          Routing(),
        ],
        child: ViewModelProvider(
          children: <Object>[
            ScreenViewModel(),
            ProjectsViewModel(
              inMemory: inMemory,
              sheetRepository: sheetRepository,
            ),
          ],
          child: Builder(builder: (BuildContext context) => child),
        ),
      );
}

final class _Styles {
  static const Map<String, Color> colors = <String, Color>{
    "light-text": Color(0xFF1f2023),
    "light-bg": Color(0xFFffffff),
    "dark-bg": Color(0xFF1c1e1e),
    "dark-text": Color(0xFFdbdde1),
  };

  ThemeData get darkTheme => ThemeData(
        fontFamily: "jetbrainsmono",
        appBarTheme: AppBarTheme(
          titleTextStyle:
              const TextStyle(fontFamily: "rubikmono", fontSize: 18),
          backgroundColor: colors["dark-bg"],
          foregroundColor: colors["dark-text"],
        ),
        dialogTheme: DialogTheme(backgroundColor: colors["dark-bg"]),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(60)),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          background: colors["dark-bg"],
          primary: colors["dark-bg"],
        ),
        textTheme: const TextTheme().copyWith(
          titleSmall:
              TextStyle(fontFamily: "firacode", color: colors["dark-text"]),
          bodySmall: TextStyle(color: colors["dark-text"]),
          bodyMedium: TextStyle(color: colors["dark-text"]),
          bodyLarge: TextStyle(color: colors["dark-text"]),
          labelSmall: TextStyle(
            fontFamily: "firacode",
            color: colors["dark-text"],
            fontSize: 18,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            fontFamily: "firacode",
            fontSize: 18,
            color: colors["dark-text"],
          ),
          hintStyle: TextStyle(
            fontFamily: "firacode",
            fontSize: 18,
            color: colors["dark-text"],
          ),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan),
          ),
          focusColor: Colors.cyan,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(colors["dark-text"]),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(fontFamily: "firacode"),
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(colors["dark-text"]),
            shadowColor: MaterialStateProperty.all(Colors.black87),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.cyanAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          contentTextStyle: TextStyle(
            fontFamily: "firacode",
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        useMaterial3: true,
      );
}
