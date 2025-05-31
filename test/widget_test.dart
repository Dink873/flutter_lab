import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/cubit/user_cubit.dart';
import 'package:my_project/main.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/repository/user_repository.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/main_screen.dart';

void main() {
  testWidgets(
    'App shows LoginScreen if not authenticated '
        'and MainScreen if autenticated',
        (WidgetTester tester) async {
      // 1. LoginScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: _LoginTestWrapper(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);

      // 2. MainScreen для авторизованого користувача
      await tester.pumpWidget(
        const MaterialApp(
          home: _MainScreenTestWrapper(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );
}

class _LoginTestWrapper extends StatelessWidget {
  const _LoginTestWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserCubit>(
      create: (_) => UserCubit(userRepository: UserRepository())
        ..emit(UserUnauthenticated()),
      child: const AppNavigator(),
    );
  }
}

class _MainScreenTestWrapper extends StatelessWidget {
  const _MainScreenTestWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserCubit>(
      create: (_) => UserCubit(userRepository: UserRepository())
        ..emit(
          UserLoaded(
            User(
              email: 'test@test.com',
              name: 'Test',
              password: '123456',
            ),
          ),
        ),
      child: const AppNavigator(),
    );
  }
}
