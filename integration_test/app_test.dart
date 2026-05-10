import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen loads with core navigation items', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('MyApp'), findsOneWidget);
    expect(find.text('Current order'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Products by shop'), findsOneWidget);
  });
}
