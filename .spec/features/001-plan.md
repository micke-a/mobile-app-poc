# Plan 001 — Bootstrap Flutter Project

Implementation plan for [`001-setup.md`](001-setup.md), grounded in [`../constitution.md`](../constitution.md).

## Context

The repository currently contains only a boilerplate Java/Gradle stub (`build.gradle.kts`, `settings.gradle.kts`, `gradle/`, `gradlew*`, `src/main/java/org/example/Main.java`) left over from an IntelliJ "new project" wizard. It has no relationship to the intended app and conflicts with Flutter's own Android Gradle config — it must be removed before scaffolding Flutter.

The constitution specifies a Flutter (iOS + Android) POC named **MyApp** using Riverpod, go_router, dio (with auth interceptor), flutter_dotenv, and JSON files in local storage. Nine screens are enumerated. There is no auth — the app is "pure local".

### Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Bundle ID / `--org` | `com.mobileapppoc.myapp` | Matches repo name. |
| dio | Scaffold + no-op `AuthInterceptor` | Honors constitution literally; ready for future HTTP. |
| JSON | Manual `toJson` / `fromJson` | Two small models; codegen is overkill. |
| iOS verification | Skipped on Windows host | iOS scaffolding is generated but `flutter build ios` requires macOS/Xcode. Android build + `flutter analyze` is the verification gate. |

---

## Step 1 — Bootstrap Flutter project with correct Gradle config

The pre-existing Java Gradle scaffold conflicts with Flutter's own Android Gradle setup (`android/build.gradle.kts` + `android/app/build.gradle.kts`). Remove the stub before scaffolding Flutter.

### 1.1 Remove the Java/Gradle stub

Preserve `.spec/`, `.gitignore`, `.idea/`, `CLAUDE.md`. Delete:

- `build.gradle.kts`
- `settings.gradle.kts`
- `gradle/`
- `gradlew`, `gradlew.bat`
- `.gradle/`
- `src/`

### 1.2 Scaffold Flutter in place

```
flutter create . --org com.mobileapppoc --project-name myapp --platforms=ios,android
```

This generates `pubspec.yaml`, `lib/main.dart`, `android/`, `ios/`, `test/`, `analysis_options.yaml`, and an updated `.gitignore`. The `android/` directory ships with Flutter's Gradle config (Kotlin DSL on recent Flutter versions) — this *is* the "suitable Gradle build" the spec references. We do not hand-author top-level Gradle.

### 1.3 Add dependencies to `pubspec.yaml`

Runtime:

- `flutter_riverpod` — state management
- `go_router` — navigation
- `dio` — HTTP (scaffolded only)
- `flutter_dotenv` — env config
- `path_provider` — resolves the app documents dir for JSON files
- `uuid` — Order id generation

Dev dependencies stay default (`flutter_lints`, `flutter_test`).

### 1.4 Configure dotenv

- Create `.env` (empty placeholder), and reference it in `pubspec.yaml` under `flutter.assets`.
- Append `.env` to `.gitignore`.
- Commit a `.env.example` template.

### 1.5 Verify Step 1

- `flutter pub get` succeeds with no errors.
- `flutter analyze` reports zero issues against the freshly generated `lib/main.dart`.

---

## Step 2 — Data model, services, router, screens

### Folder layout

```
lib/
  main.dart
  router/app_router.dart
  models/product.dart
  models/order.dart
  services/local_storage_service.dart
  services/http_client.dart          // dio + no-op AuthInterceptor
  repositories/product_repository.dart
  repositories/order_repository.dart
  providers/
    storage_providers.dart
    product_providers.dart
    order_providers.dart
  screens/
    login_screen.dart
    home_screen.dart
    products_screen.dart
    products_by_shop_screen.dart
    favourites_screen.dart
    add_product_screen.dart
    product_detail_screen.dart
    orders_screen.dart
    order_detail_screen.dart
```

### 2.1 Models (manual JSON, immutable with `copyWith`)

- `Product { String name; String shop; bool favorite; }` + `toJson` / `fromJson`.
- `Order { String id; DateTime createdDate; List<Product> products; }` + `toJson` / `fromJson`. `id` defaults to `Uuid().v4()`, `createdDate` defaults to `DateTime.now()` at construction.

### 2.2 Local storage service — `LocalStorageService`

- Resolves `getApplicationDocumentsDirectory()` once via `path_provider`.
- `Future<List<T>> readList<T>(String filename, T Function(Map) fromJson)` — returns `[]` if file missing.
- `Future<void> writeList<T>(String filename, List<T> items, Map Function(T) toJson)` — writes pretty-printed JSON.
- Files: `products.json`, `orders.json`.

### 2.3 HTTP client

`buildDio()` returns a `Dio` with base options sourced from dotenv and a single `AuthInterceptor` whose `onRequest` is currently a pass-through. Stub only; not invoked anywhere yet.

### 2.4 Riverpod providers

- `localStorageServiceProvider` — `Provider<LocalStorageService>`.
- `productRepositoryProvider`, `orderRepositoryProvider` — `Provider`s wrapping the storage service.
- `productListProvider`, `orderListProvider` — `AsyncNotifierProvider`s exposing CRUD ops (add, toggle favorite, filter by shop, etc.).

### 2.5 Router

`appRouterProvider` returns a `GoRouter` with the nine routes from the constitution. Initial location: `/login`. No auth guard (since no auth) — `/login` is a stub that navigates to `/home` on tap.

### 2.6 Screens (minimal but functional stubs)

- **`LoginScreen`** — email + password `TextField`s and a "Sign in" button that calls `context.go('/home')`. Inputs are not validated or stored.
- **`HomeScreen`** — links to `/products`, `/products/favourites`, `/orders`.
- **`ProductsScreen`** — `ConsumerWidget` watching `productListProvider`; `ListView` with a search `TextField` filtering by name. Tile tap → `/product/:id`.
- **`ProductsByShopScreen`** — same list, filtered by `:shop` path param.
- **`FavouritesScreen`** — same list, filtered by `favorite == true`.
- **`AddProductScreen`** — form (name + shop); submit calls `productListProvider.notifier.add(...)`, then `context.pop()`.
- **`ProductDetailScreen`** — shows product; "Add to order" button creates a single-item Order and navigates to `/order/:id`.
- **`OrdersScreen`** — lists orders by `createdDate` desc.
- **`OrderDetailScreen`** — shows order header + product list.

**Note on `Product` id:** the constitution's `Product` schema has no `id` field. For the `/product/:id` route, use the product's index in the persisted list as the id. If that proves awkward during execution, fall back to keying by `name + shop` and document the choice in code.

### 2.7 `main.dart`

```dart
await dotenv.load(fileName: '.env');
runApp(const ProviderScope(child: MyApp()));
```

`MyApp` is a `ConsumerWidget` building `MaterialApp.router(routerConfig: ref.watch(appRouterProvider))`.

---

## Step 3 — Verify build

Run from project root:

1. `flutter pub get` — no errors.
2. `flutter analyze` — zero issues.
3. `flutter test` — the default counter test no longer matches the rewritten `lib/main.dart`. Delete `test/widget_test.dart`; widget tests are out of scope for the bootstrap.
4. `flutter build apk --debug` — produces `build/app/outputs/flutter-apk/app-debug.apk`.
5. **iOS skipped** (Windows host). `ios/` is generated but unverified locally — this is expected and explicit.

If any step fails, fix before declaring Step 3 complete.

---

## Critical files

Created during execution:

- `pubspec.yaml`
- `.env`, `.env.example`
- `lib/main.dart`
- `lib/router/app_router.dart`
- `lib/models/product.dart`, `lib/models/order.dart`
- `lib/services/local_storage_service.dart`, `lib/services/http_client.dart`
- `lib/repositories/*.dart`, `lib/providers/*.dart`
- `lib/screens/*.dart` (9 files)
- `android/app/build.gradle.kts` — auto-generated; verify `applicationId` reads `com.mobileapppoc.myapp` after `flutter create`.

Removed:

- `build.gradle.kts`, `settings.gradle.kts`, `gradle/`, `gradlew`, `gradlew.bat`, `.gradle/`, `src/`.

---

## End-to-end verification gate

Before declaring `001-setup` complete:

1. `flutter pub get` — clean.
2. `flutter analyze` — 0 issues.
3. `flutter build apk --debug` — succeeds.
4. Manually launch on an Android emulator (`flutter run`): log in, browse to `/products`, add a product, restart the app, and confirm the product persists by reading `products.json` from the application documents directory.
