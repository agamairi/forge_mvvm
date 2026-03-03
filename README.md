# forge_mvvm

> **A Flutter framework that teaches you to write better apps.**
> Enforces MVVM architecture and Clean Code principles through compile-time contracts,
> runtime assertions, navigation patterns, pagination, form validation, and a
> built-in CLI scaffolding tool.

[![pub.dev](https://img.shields.io/pub/v/forge_mvvm.svg)](https://pub.dev/packages/forge_mvvm)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue)](https://dart.dev)

---

## Table of Contents

- [Why forge\_mvvm?](#why-forge_mvvm)
- [Architecture Overview](#architecture-overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Layer Guide](#layer-guide)
  - [UI Layer — ForgeView & ForgeViewModel](#ui-layer--forgeview--forgeviewmodel)
  - [Domain Layer — UseCase](#domain-layer--forgeusecases)
  - [Data Layer — Repository & Service](#data-layer--forgerepository--forgeservice)
  - [ForgeResult](#forgeresult--type-safe-outcomes)
  - [ForgeCommand](#forgecommand--async-actions)
  - [ForgeNavigator](#forgenavigator--navigation)
  - [ForgePaginatedViewModel](#forgepaginatedviewmodel--pagination)
  - [ForgeFormViewModel](#forgeformviewmodel--form-validation)
  - [ForgeLocator — DI](#dependency-injection--forgelocator)
- [Project Structure](#project-structure)
- [Bootstrap](#bootstrap--forgeappsetup)
- [forge\_cli](#forge_cli--scaffolding-tool)
- [Testing](#testing)
- [Architecture Enforcement Rules](#architecture-enforcement-rules)
- [iOS Parallel](#ios-parallel)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

---

## Why forge\_mvvm?

Most Flutter architecture packages give you tools. `forge_mvvm` gives you **guardrails**.

| Problem | forge_mvvm solution |
|---|---|
| Business logic leaking into widgets | `ForgeView` compile-time contract — `BuildContext` never enters a ViewModel |
| ViewModels reaching directly into Services | Runtime assertion stops you at bootstrap |
| Forgetting to write tests | Every CLI scaffold generates a **failing stub** you must replace |
| Loading/error boilerplate on every screen | `runBusyAction` + `ForgeStateWidget` remove ~80% of it |
| No safe place for navigation in a ViewModel | `NavigationEvent` stream — ViewModel emits, View navigates |
| Reinventing pagination every feature | `ForgePaginatedViewModel` — one override, full page management |
| Scattered form validation logic | `ForgeFormViewModel` — per-field errors, one `validateAll()` call |

---

## Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                    UI LAYER                      │
│  ForgeView  ◄──►  ForgeViewModel                 │
│                   ForgeCommand                   │
│                   ForgePaginatedViewModel        │
│                   ForgeFormViewModel             │
├──────────────────────────────────────────────────┤
│                  DOMAIN LAYER                    │
│               ForgeUseCase                       │
│            ForgeRepository (abstract contract)   │
├──────────────────────────────────────────────────┤
│                   DATA LAYER                     │
│       ForgeRepository (impl) ◄► ForgeService     │
└──────────────────────────────────────────────────┘
                         │
                  ForgeNavigator
               (go_router bridge — View layer)
```

**Dependency rule:** each layer depends only on the layer directly below it, and only
through abstractions (abstract classes / interfaces). This mirrors iOS Clean Architecture
with SwiftUI — learning one transfers directly to the other.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  forge_mvvm: ^0.2.0
```

```bash
flutter pub get
```

> **Requirements:** Flutter ≥ 3.10.0 · Dart ≥ 3.0.0

---

## Quick Start

### 1. Bootstrap in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ForgeApp.setUp(
    services: [() => AuthServiceImpl()],
    repositories: [
      () => AuthRepositoryImpl(ForgeLocator.get<AuthServiceImpl>()),
    ],
  );

  // Register the abstract interface so ForgeLocator.get<AuthRepository>() works
  ForgeLocator.registerSingleton<AuthRepository>(
    ForgeLocator.get<AuthRepositoryImpl>(),
  );

  runApp(const MyApp());
}
```

### 2. Create a ViewModel

```dart
class LoginViewModel extends ForgeViewModel {
  LoginViewModel(AuthRepository repository)
      : _loginUseCase = LoginUseCase(repository);

  final LoginUseCase _loginUseCase;

  String _email = '';
  String _password = '';

  String get email => _email;
  String get password => _password;

  void setEmail(String v) { _email = v; notifyListeners(); }
  void setPassword(String v) { _password = v; notifyListeners(); }

  Future<void> login() async {
    await runBusyAction(() async {
      final result = await _loginUseCase.execute(
        LoginParams(email: _email, password: _password),
      );
      result.when(
        success: (user) => _currentUser = user,
        failure: (e)    => setError(e.toString()),
      );
    });
  }
}
```

### 3. Create a View

```dart
class LoginView extends ForgeView<LoginViewModel> {
  const LoginView({super.key});

  @override
  LoginViewModel createViewModel(BuildContext context) =>
      LoginViewModel(ForgeLocator.get<AuthRepository>());

  @override
  Widget buildView(BuildContext context, LoginViewModel vm) {
    return ForgeStateWidget(
      viewModel: vm,
      data: (ctx, vm) => LoginForm(vm: vm),
    );
  }
}
```

That is the complete pattern. Every screen in your app follows these three steps.

---

## Layer Guide

### UI Layer — ForgeView & ForgeViewModel

#### ForgeView

`ForgeView<T extends ForgeViewModel>` is an abstract `StatefulWidget`. You must implement
exactly two methods — the framework wires everything else automatically.

| Method | Purpose |
|---|---|
| `createViewModel(BuildContext)` | Instantiate + inject the ViewModel (called once on mount) |
| `buildView(BuildContext, T vm)` | Build the widget tree from current ViewModel state |

The framework automatically:
- Wraps the widget in a `ChangeNotifierProvider<T>`
- Calls `vm.onInit()` on mount
- Calls `vm.dispose()` on unmount

**Rule enforced (compile-time):** You cannot instantiate a `ForgeView` subclass without
implementing both methods.

#### ForgeViewModel

```dart
abstract class ForgeViewModel extends ChangeNotifier { ... }
```

| Member | Description |
|---|---|
| `isLoading` | `true` while `runBusyAction` is executing |
| `errorMessage` | Latest error string, or `null` |
| `onInit()` | Called once on mount — override for initial data fetching |
| `onDispose()` | Called before destroy — override to cancel subscriptions |
| `runBusyAction(fn)` | Wraps async work: sets loading, catches exceptions, clears loading |
| `setLoading(bool)` | Manual loading control |
| `setError(String)` | Sets an error message |
| `clearError()` | Clears the current error |

**Rule enforced:** `BuildContext` is never passed into a ViewModel. All navigation is
handled via `NavigationEvent` streams (see [ForgeNavigator](#forgenavigator--navigation)).

#### ForgeStateWidget

Eliminates the `if (vm.isLoading) … else if (vm.errorMessage != null) …` boilerplate:

```dart
ForgeStateWidget<MyViewModel>(
  viewModel: vm,
  loading: (_) => const CircularProgressIndicator(),
  error: (_, msg) => ErrorBanner(message: msg),
  data: (_, vm) => MyContentWidget(vm: vm),
)
```

If `loading` or `error` are omitted, sensible defaults are used.

---

### Domain Layer — ForgeUseCases

A `ForgeUseCase` encapsulates exactly one piece of business logic and depends only on
a `ForgeRepository` abstract contract.

```dart
class LoginUseCase extends ForgeUseCase<LoginParams, ForgeResult<User>> {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<ForgeResult<User>> execute(LoginParams params) =>
      _repository.login(params.email, params.password);
}
```

For use cases with no input parameters:

```dart
class GetCurrentSessionUseCase extends ForgeUseCaseNoParams<ForgeResult<Session>> {
  @override
  Future<ForgeResult<Session>> execute() => _repository.currentSession();
}
```

---

### Data Layer — ForgeRepository & ForgeService

#### Repository contract (domain layer)

```dart
// domain/repositories/user_repository.dart
abstract class UserRepository extends ForgeRepository {
  Future<ForgeResult<User>> fetchById(String id);
  Future<ForgeResult<List<User>>> fetchAll();
  Future<void> save(User user);
}
```

#### Repository implementation (data layer)

```dart
// data/repositories/user_repository_impl.dart
class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(this._service);
  final UserService _service;

  @override
  Future<ForgeResult<User>> fetchById(String id) async {
    try {
      final dto = await _service.getUser(id);
      return ForgeResult.success(dto.toUser());
    } on ForgeException catch (e) {
      return ForgeResult.failure(e);
    }
  }
}
```

#### Service (data layer only)

`ForgeService` is the outermost data-access layer (HTTP clients, local DB, sensors).
Services must **never** be accessed directly from a ViewModel or UseCase.

```dart
abstract class UserService extends ForgeService {
  Future<UserDto> getUser(String id);
}
```

---

### ForgeResult — Type-Safe Outcomes

`ForgeResult<T>` is a sealed class that forces you to handle both success and failure
at every call site. There are no silent `null` returns.

```dart
final result = await _loginUseCase.execute(params);

// Pattern 1 — when() (exhaustive, recommended)
result.when(
  success: (user) => _navigateToHome(user),
  failure: (e)    => setError(e.toString()),
);

// Pattern 2 — switch expression (Dart 3+)
final label = switch (result) {
  ForgeSuccess(:final data)      => 'Welcome ' + data.name,
  ForgeFailure(:final exception) => 'Error: ' + exception.toString(),
};

// Pattern 3 — nullable getters
final user  = result.dataOrNull;
final error = result.exceptionOrNull;
```

#### Built-in exceptions

| Class | Use for |
|---|---|
| `ForgeException` | Base class — extend for feature-specific exceptions |
| `ForgeNetworkException` | HTTP / connectivity failures |
| `ForgeServerException` | Unexpected server responses |
| `ForgeCacheException` | Local storage failures |
| `ForgeValidationException` | Input validation failures |

---

### ForgeCommand — Async Actions

`ForgeCommand<T>` wraps a single async action, tracks its own `isRunning`/`lastException`
state, and **prevents double-submission** automatically.

```dart
// In ViewModel
late final loginCommand = ForgeCommand<void>((_) => _performLogin());

// In View — button disables itself while running
ElevatedButton(
  onPressed: vm.loginCommand.isRunning ? null : vm.loginCommand.execute,
  child: vm.loginCommand.isRunning
      ? const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Text('Login'),
)
```

Calling `execute()` while already running is a no-op — no guards needed in your code.

---

### ForgeNavigator — Navigation

ViewModels must never hold a `BuildContext`. Instead, emit `NavigationEvent`s via a
`StreamController` and let the View handle routing. This mirrors the iOS **Coordinator**
pattern.

#### Step 1 — Add a navigation stream to your ViewModel

```dart
class LoginViewModel extends ForgeViewModel {
  final _navController = StreamController<NavigationEvent>.broadcast();
  Stream<NavigationEvent> get navigationEvents => _navController.stream;

  Future<void> login() async {
    await runBusyAction(() async {
      final result = await _loginUseCase.execute(...);
      result.when(
        success: (_) => _navController.add(const ReplaceRoute('/home')),
        failure: (e) => setError(e.toString()),
      );
    });
  }

  @override
  void onDispose() => _navController.close();
}
```

#### Step 2 — Register ForgeNavigator at bootstrap

```dart
final router = GoRouter(routes: [...]);

ForgeLocator.registerSingleton<ForgeNavigator>(ForgeNavigator(router));
```

#### Step 3 — Listen in the View

```dart
@override
LoginViewModel createViewModel(BuildContext context) {
  final vm = LoginViewModel(ForgeLocator.get<AuthRepository>());
  vm.navigationEvents.listen((event) {
    ForgeLocator.get<ForgeNavigator>().handle(event, context);
  });
  return vm;
}
```

#### Available events

| Event | Behaviour |
|---|---|
| `PushRoute('/path')` | Pushes a new route (back button remains) |
| `ReplaceRoute('/path')` | Replaces the stack (no back button) |
| `PopRoute()` | Pops the top route |

---

### ForgePaginatedViewModel — Pagination

Page-based pagination with one method to implement.

```dart
class ArticleListViewModel extends ForgePaginatedViewModel<Article> {
  ArticleListViewModel(this._repository);
  final ArticleRepository _repository;

  @override
  Future<List<Article>> loadPage(int page) async {
    final result = await _repository.getArticles(page: page, limit: 20);
    return result.dataOrNull ?? [];
  }
}
```

#### In your View

```dart
@override
void onInit() => loadNextPage(); // kick off first page

// Attach to a scroll listener for infinite scroll:
NotificationListener<ScrollNotification>(
  onNotification: (n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      vm.loadNextPage();
    }
    return false;
  },
  child: ListView.builder(
    itemCount: vm.items.length + (vm.isLoadingMore ? 1 : 0),
    itemBuilder: (ctx, i) => i < vm.items.length
        ? ArticleCard(article: vm.items[i])
        : const Center(child: CircularProgressIndicator()),
  ),
)
```

#### API

| Member | Description |
|---|---|
| `items` | All loaded items across all pages |
| `currentPage` | The last successfully loaded page number |
| `hasMore` | `false` once a page returns an empty list |
| `isLoadingMore` | `true` while a page fetch is in progress |
| `loadNextPage()` | Fetches the next page; no-op if already loading or exhausted |
| `refresh()` | Clears all items and reloads from page 1 |

---

### ForgeFormViewModel — Form Validation

Per-field validation with a single `validateAll()` call.

```dart
class SignUpViewModel extends ForgeFormViewModel {
  String email = '';
  String password = '';

  @override
  bool validateAll() {
    if (email.isEmpty) {
      setFieldError('email', 'Email is required');
    } else if (!email.contains('@')) {
      setFieldError('email', 'Enter a valid email');
    } else {
      setFieldError('email', null); // clears the error
    }

    setFieldError(
      'password',
      password.length < 6 ? 'Minimum 6 characters' : null,
    );

    return isValid;
  }
}
```

#### In your View

```dart
// Field with inline error
TextField(
  onChanged: (v) { vm.email = v; },
  decoration: InputDecoration(
    labelText: 'Email',
    errorText: vm.errorFor('email'),
  ),
)

// Submit button
ElevatedButton(
  onPressed: () {
    if (vm.validateAll()) vm.submit();
  },
  child: const Text('Sign Up'),
)
```

#### API

| Member | Description |
|---|---|
| `isValid` | `true` after `validateAll()` passes with no field errors |
| `validateAll()` | Override to validate fields; returns `isValid` |
| `setFieldError(key, message)` | Set or clear (`null`) error for a field key |
| `errorFor(key)` | Get the current error for a field key |
| `clearFieldErrors()` | Clears all field errors |
| `fieldErrors` | Unmodifiable map of all current field errors |

---

### Dependency Injection — ForgeLocator

`ForgeLocator` is a thin wrapper around [get_it](https://pub.dev/packages/get_it).
All registrations go through `ForgeApp.setUp()` which enforces layer order.

```dart
await ForgeApp.setUp(
  services: [
    () => ApiService(baseUrl: 'https://api.example.com'),
    () => LocalStorageService(),
  ],
  repositories: [
    () => UserRepositoryImpl(ForgeLocator.get<ApiService>()),
    () => AuthRepositoryImpl(ForgeLocator.get<ApiService>()),
  ],
);

// Register abstract interfaces after setUp
ForgeLocator.registerSingleton<UserRepository>(
  ForgeLocator.get<UserRepositoryImpl>(),
);
```

Resolve in `createViewModel`:

```dart
@override
ProfileViewModel createViewModel(BuildContext context) =>
    ProfileViewModel(ForgeLocator.get<UserRepository>());
```

#### Additional registration methods

```dart
ForgeLocator.registerLazySingleton<T>(() => MyService());  // created on first get
ForgeLocator.registerFactory<T>(() => MyViewModel());      // new instance each time
ForgeLocator.registerSingleton<T>(existingInstance);       // pre-created instance
```

---

## Project Structure

This structure is enforced by the CLI and mirrors both Flutter's official architecture
guide and iOS feature-module conventions.

```
lib/
├── main.dart                           ← ForgeApp.setUp() + GoRouter
├── app/
│   └── app.dart                        ← MaterialApp / routing
└── features/
    └── login/                          ← One folder per feature
        ├── data/
        │   ├── services/
        │   │   ├── auth_service.dart          ← abstract ForgeService
        │   │   └── auth_service_impl.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── models/
        │   │   └── user.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart       ← abstract ForgeRepository
        │   └── usecases/
        │       ├── login_usecase.dart
        │       └── login_params.dart
        └── ui/
            ├── login_view.dart
            └── login_viewmodel.dart

test/
└── features/
    └── login/
        └── login_viewmodel_test.dart   ← always required
```

---

## Bootstrap — ForgeApp.setUp()

```dart
await ForgeApp.setUp(
  services:         [...],  // ForgeService factories  — registered first
  repositories:     [...],  // ForgeRepository factories — registered second
  resetForTesting:  false,  // pass true inside test setUp()
);
```

| Parameter | Type | Description |
|---|---|---|
| `services` | `List<Object Function()>` | Service factories — innermost layer, registered first |
| `repositories` | `List<Object Function()>` | Repository factories — depend on services |
| `resetForTesting` | `bool` | Clears all DI registrations — use in `test setUp()` |

Calling `setUp()` twice without `resetForTesting: true` throws a `StateError` with a
clear message. In debug mode, a summary is printed on successful bootstrap.

---

## forge\_cli — Scaffolding Tool

The CLI lives at `bin/forge_cli.dart` and is run via:

```bash
dart run bin/forge_cli.dart <command> [args]
```

### Commands

#### `create feature <name>`

Scaffolds a complete, clean-architecture feature module:

```bash
dart run bin/forge_cli.dart create feature profile
```

Creates:
```
lib/features/profile/
├── domain/
│   ├── models/
│   ├── repositories/profile_repository.dart   ← abstract contract
│   └── usecases/
├── data/
│   ├── services/
│   └── repositories/
└── ui/
    ├── profile_view.dart       ← ForgeView stub
    └── profile_viewmodel.dart  ← ForgeViewModel stub

test/features/profile/
└── profile_viewmodel_test.dart ← FAILING STUB you must implement
```

The generated test file contains a **deliberately failing test** — your CI pipeline will
block until you implement real tests for the feature.

#### `check`

Runs `flutter analyze` followed by `flutter test`. Exits with a non-zero code if either
fails, making it safe to use as a CI gate:

```bash
dart run bin/forge_cli.dart check
```

#### `test`

Alias for `flutter test`:

```bash
dart run bin/forge_cli.dart test
```

---

## Testing

`forge_mvvm` is designed so that every ViewModel is fully unit-testable without a widget
tree or running Flutter engine.

### ForgeTestHarness

```dart
void main() {
  late LoginViewModel sut;
  final harness = ForgeTestHarness();

  setUp(() async {
    await harness.setUp();           // resets DI for a clean state
    sut = LoginViewModel(MockAuthRepository());
    harness.initViewModel(sut);     // calls onInit() as ForgeView would
  });

  tearDown(() => sut.dispose());

  test('sets currentUser on successful login', () async {
    sut.setEmail('a@b.com');
    sut.setPassword('password');
    await sut.login();
    expect(sut.isLoggedIn, isTrue);
    expect(sut.currentUser!.email, equals('a@b.com'));
  });

  test('sets errorMessage on failed login', () async {
    // arrange mock to return failure
    await sut.login();
    expect(sut.errorMessage, isNotNull);
    expect(sut.isLoggedIn, isFalse);
  });
}
```

### ForgeMockRepository

Extend this instead of a raw class to satisfy the type system cleanly:

```dart
class MockAuthRepository extends ForgeMockRepository implements AuthRepository {
  @override
  Future<ForgeResult<User>> login(String email, String password) async =>
      ForgeResult.success(const User(id: '1', email: 'a@b.com', name: 'Dev'));
}
```

### Running tests

```bash
flutter test                          # all tests
flutter test test/ui/                 # UI layer only
flutter test test/features/login/     # one feature
dart run bin/forge_cli.dart check     # analyze + test (CI-safe)
```

---

## Architecture Enforcement Rules

| Rule | Enforcement | Violation result |
|---|---|---|
| `ForgeView` must bind to a `ForgeViewModel` | Compile-time | Won't compile |
| `createViewModel` + `buildView` must be implemented | Compile-time | Won't compile |
| `ForgeUseCase.execute()` must be implemented | Compile-time | Won't compile |
| `ForgeFormViewModel.validateAll()` must be implemented | Compile-time | Won't compile |
| `ForgePaginatedViewModel.loadPage()` must be implemented | Compile-time | Won't compile |
| Services registered before Repositories | Runtime `StateError` | Clear message on bootstrap |
| `ForgeLocator.get<T>()` on unregistered type | Runtime `AssertionError` | Descriptive message in debug |
| `notifyListeners()` after `dispose()` | Runtime guard | Silent no-op — no crash |
| Tests per feature | CLI failing stub | CI blocks until tests are written |

---

## iOS Parallel

`forge_mvvm` is deliberately structured to mirror iOS Clean Architecture with SwiftUI.
Learning here transfers directly to native iOS.

| forge_mvvm (Flutter / Dart) | iOS / SwiftUI equivalent |
|---|---|
| `ForgeView<T>` | `struct MyView: View` + `@StateObject` |
| `ForgeViewModel` + `ChangeNotifier` | `@Observable` / `ObservableObject` class |
| `ForgeRepository` (abstract) | `protocol UserRepository` |
| `ForgeRepository` (impl) | `class UserRepositoryImpl: UserRepository` |
| `ForgeService` | `URLSession`-based API client / `SwiftData` store |
| `ForgeUseCase` | `Interactor` / `UseCase` struct |
| `ForgeLocator` | Swift `DIContainer` / `@Environment` |
| `ForgeResult<T>` | `Result<T, Error>` |
| `ForgeException` | `Error` protocol |
| `NavigationEvent` + `ForgeNavigator` | Coordinator / `NavigationPath` |
| `ForgePaginatedViewModel` | `AsyncSequence`-backed list ViewModel |
| `ForgeFormViewModel` | `@FocusState` + field-level validation pattern |

---

## FAQ

**Q: Can I use Riverpod or Bloc instead of Provider?**
`forge_mvvm` uses `ChangeNotifier` + `Provider` internally, which is the Flutter team's
own recommended lightweight state management. Switching to Riverpod or Bloc would defeat
the guardrails the framework provides.

**Q: Does ForgeLocator replace all get_it usage?**
Yes. Never call `GetIt.instance` directly — always use `ForgeLocator` so the
architectural layer rules are visible and enforceable.

**Q: Can I use forge_mvvm in an existing project?**
Yes. Introduce it feature-by-feature. Existing code does not need to be migrated all at
once. Start by wrapping new features in `ForgeView` / `ForgeViewModel`, then migrate old
screens as you touch them.

**Q: What if my ViewModel needs to navigate?**
Add a `StreamController<NavigationEvent>` to your ViewModel and expose a
`Stream<NavigationEvent>` getter. Listen in `createViewModel` and call
`ForgeLocator.get<ForgeNavigator>().handle(event, context)`. See
[ForgeNavigator](#forgenavigator--navigation) for the full example.

**Q: How do I register abstract repository interfaces?**
After `ForgeApp.setUp()`, call:
```dart
ForgeLocator.registerSingleton<MyRepository>(
  ForgeLocator.get<MyRepositoryImpl>(),
);
```
This lets `ForgeLocator.get<MyRepository>()` resolve correctly in `createViewModel`.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Add your changes and **write tests** — PRs without tests will not be merged
4. Run `dart run bin/forge_cli.dart check` and confirm it passes
5. Submit a pull request with a clear description of what was added and why

---

## License

MIT — see [LICENSE](LICENSE).
