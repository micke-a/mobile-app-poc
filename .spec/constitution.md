# Project: MyApp

## Stack decisions

- Main framework: Flutter (3.41.x stable, Dart 3.11.x)
- Platforms: Android + iOS (iOS scaffolding present but unverified from Windows hosts)
- Bundle / package ID: `com.mobileapppoc.myapp`
- State management: Riverpod (`flutter_riverpod`)
- Navigation: go_router
- HTTP: dio, scaffolded with a no-op `AuthInterceptor` for future use; not currently wired into any feature
- Local storage: JSON files in the app documents directory (`path_provider`)
- Auth: none — pure local application
- Env config: flutter_dotenv (`.env`, ignored by git; `.env.example` is the template)

## Android targets

- compileSdk: 36
- targetSdk: 36
- minSdk: 24

## Data model

AppState:
* currentOrder: Order? , products are added to this order when the user taps the "Add to order" button
* currentShop: Shop? , used for default filtering on the /products screen

Shop:
* id: number
* name

Product
* id: UUID (generated)
* name: String (name of the item at the shop)
* shop: Shop (Tesco, Ocado, etc.)
* favorite: bool (whether the user has favorited this product)

Order
* id: UUID (generated)
* createdDate: timestamp (generated)
* products: List<Product>

Data sources:
* All persistence is local JSON: `products.json`, `orders.json`, `shops.json`, `current-order.json` under the app documents directory
* No remote/API persistence

## Screen inventory

* `/home` — dashboard, entry point of the app
* `/products` — scrollable product list with search
* `/products/shop/:shop` — filter products by shop
* `/products/favourites` — filter to favourited products
* `/products/add` — add a new product
* `/product/:id` — product detail, add to order
* `/orders` — order history list
* `/order/:id` — order detail

## References

* Setup & emulator instructions: [`README.md`](../README.md)
* Feature plans & deltas: [`.spec/features/`](features/)

## Integration testing

### Setup (already done)
- `integration_test` SDK package is listed under `dev_dependencies` in `pubspec.yaml`
- Test files live in `integration_test/` at project root

### Writing a test
Every integration test file must:
1. Import `package:integration_test/integration_test.dart`
2. Call `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` as the first line of `main()`
3. Import `package:myapp/main.dart` as `app` and call `app.main()` to boot the full app — this ensures `dotenv.load()` runs before `runApp()`
4. Use `await tester.pumpAndSettle()` after booting to let navigation and animations settle

Minimal template:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('description', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    // assertions here
  });
}
```

### Running tests
Requires a running Android emulator or connected device.

```bash
# Run a specific test file
flutter test integration_test/app_test.dart

# Run all integration tests
flutter test integration_test/
```

### Key finders
- `find.text('...')` — find by visible text
- `find.byKey(const Key('...'))` — find by widget key (preferred for interactive elements)
- `find.byIcon(Icons.xxx)` — find by icon

### Gotchas
- `.env` must exist at project root (it is gitignored; copy from `.env.example`). It is bundled as a Flutter asset so integration tests can load it.
- Use `pumpAndSettle()` rather than `pump()` when navigation or animations are involved
- The `integration_test` package must come from `sdk: flutter`, not pub.dev (the pub.dev version is discontinued and Dart-3-incompatible)

## UI design

- Design system: Material 3 (`useMaterial3: true`)
- Theme file: [`lib/core/app_theme.dart`](../lib/core/app_theme.dart) — defines `lightTheme()` and `darkTheme()`
- Font: [Inter](https://fonts.google.com/specimen/Inter) via `google_fonts` package
- Seed color: `Color(0xFF006874)` (deep teal); drives the full M3 color scheme via `ColorScheme.fromSeed`
- Dark mode: follows system setting (`ThemeMode.system`)

### Fine-tuning colors

Edit the `seedColor` in `app_theme.dart` to shift the whole palette, or override individual roles:

```dart
colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF...)).copyWith(
  primary: const Color(0xFF...),
  secondary: const Color(0xFF...),
)
```

Use the [Material Theme Builder](https://m3.material.io/theme-builder) to preview palettes before committing.

### Fine-tuning typography

Replace `GoogleFonts.interTextTheme()` in both `lightTheme()` and `darkTheme()` with any other Google Font:

```dart
GoogleFonts.plusJakartaSansTextTheme()  // rounder, friendlier
GoogleFonts.dmSansTextTheme()           // clean, geometric
```

Or override individual text styles:

```dart
textTheme: GoogleFonts.interTextTheme().copyWith(
  displayLarge: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w700),
)
```
