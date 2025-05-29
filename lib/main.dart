import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_project/cubit/user_cubit.dart';
import 'package:my_project/repository/user_repository.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/main_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/register_screen.dart';
import 'package:my_project/screens/setting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(),
        ),
      ],
      child: BlocProvider<UserCubit>(
        create: (context) => UserCubit(
          userRepository: RepositoryProvider.of<UserRepository>(context),
        )..checkLoginStatus(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Coffee',
          theme: ThemeData(primarySwatch: Colors.brown),
          home: const AppNavigator(), // ДОДАЙ const тут
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => const MainScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is UserLoaded) {
          return const MainScreen();
        } else if (state is UserUnauthenticated) {
          return const LoginScreen();
        } else if (state is UserError) {
          return Scaffold(
            body: Center(child: Text('Помилка: ${(state).message}')),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Невідомий стан')),
          );
        }
      },
    );
  }
}
