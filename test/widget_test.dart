import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/main.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Navigation based on login status', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', false);

    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);

    await prefs.setBool('isLoggedIn', true);

    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
