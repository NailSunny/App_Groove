import 'package:flutter_test/flutter_test.dart';
import 'package:groove_app/api_service/cart_provider.dart';
import 'package:groove_app/app/app_flavor.dart';
import 'package:groove_app/app/groove_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mobile app shows login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    AppScope.flavor = AppFlavor.mobile;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const GrooveApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
  });
}
