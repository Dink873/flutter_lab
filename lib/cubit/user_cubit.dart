import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_project/models/user.dart';
import 'package:my_project/repository/user_repository.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class UserUnauthenticated extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
  @override
  List<Object?> get props => [message];
}

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;

  UserCubit({required this.userRepository}) : super(UserInitial());

  Future<void> checkLoginStatus() async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUser();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserUnauthenticated());
      }
    } catch (e) {
      emit(UserError('Помилка перевірки логіну: $e'));
    }
  }

  Future<void> login(String email, String password) async {
    emit(UserLoading());
    try {
      final success = await userRepository.loginUser(email, password);
      if (success) {
        final user = await userRepository.getUser();
        emit(UserLoaded(user!));
      } else {
        emit(UserError('Невірний логін або пароль'));
      }
    } catch (e) {
      emit(UserError('Помилка входу: $e'));
    }
  }

  Future<void> register(String email, String password) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUser();
      if (user != null && user.email == email) {
        emit(UserError('Користувач з таким email вже існує'));
        return;
      }
      final newUser = User(email: email, name: email, password: password);
      await userRepository.registerUser(newUser);
      emit(UserLoaded(newUser));
    } catch (e) {
      emit(UserError('Помилка реєстрації: $e'));
    }
  }

  Future<void> logout() async {
    emit(UserLoading());
    try {
      await userRepository.logout();
      emit(UserUnauthenticated());
    } catch (e) {
      emit(UserError('Помилка виходу: $e'));
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    emit(UserLoading());
    try {
      await userRepository.updateSettings(settings);
      final updatedUser = await userRepository.getUser();
      emit(UserLoaded(updatedUser!));
    } catch (e) {
      emit(UserError('Помилка збереження налаштувань: $e'));
    }
  }
}
