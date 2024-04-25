# late

```dart
ProjectsViewModel({
  required this.sheetRepository, //initialize first
  required this.inMemory,
});

//after constructor, initialized lately
late BehaviorSubject<List<Project>> projectsController = BehaviorSubject.seeded(inMemory.projects);
```

# static initialization

```dart

class SheetRepository {
  factory SheetRepository.getInstance(LocalStorage localStorage) {
    return SheetRepository._(localStorage: localStorage);
  }

  static GSheets? client;
  static Map<String, dynamic>? credential;

  static Future<void> readJson() async {
    final json = await rootBundle.loadString(filePath);
    credential = jsonDecode(json);
    if (credential != null) {
      client = GSheets(credential);
    } else {
      throw Exception("not initialized credential");
    }
  }
}

```

```
void main() {
  final SheetRepository sheetRepository = SheetRepository.getInstance(localStorage); //intialize with late(uninitialized static value)

  try {
    await Future.wait([
      SheetRepository.readJson(), //initialize late static value
    ]).whenComplete(...)
}
```

# using stream inner widget

```
final LoaderViewModel screenViewModel =
  ViewModelProvider.of<LoaderViewModel>(context);

late bool isBusy;
screenViewModel.state$.listen((state) => switch (state.unwrap()) {
  LoadingState() => isBusy = true,
  LoadedErrorState() => isBusy = false,
  LoadedState() => isBusy = false,
});
```