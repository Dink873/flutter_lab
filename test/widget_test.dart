import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/main.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Navigation based on login status', (WidgetTester tester) async {
    // Ініціалізуємо SharedPreferences перед тестом
    final prefs = await SharedPreferences.getInstance();

    // Установлюємо значення для isLoggedIn в SharedPreferences (false для неавторизованого користувача)
    await prefs.setBool('isLoggedIn', false);

    // Створюємо віджет з переданим значенням isLoggedIn
    await tester.pumpWidget(MyApp(isLoggedIn: false));

    // Перевіряємо, що сторінка логіну відображається
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);

    // Тепер встановлюємо isLoggedIn як true (для авторизованого користувача)
    await prefs.setBool('isLoggedIn', true);

    // Створюємо віджет з переданим значенням isLoggedIn
    await tester.pumpWidget(MyApp(isLoggedIn: true));

    // Перевіряємо, що головна сторінка відображається
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
