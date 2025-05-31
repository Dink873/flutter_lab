import 'package:my_project/data/local_storage.dart';
import 'package:my_project/models/user.dart';

class UserRepository {
  final LocalStorage storage;

  UserRepository() : storage = SharedPrefsStorage();

  UserRepository.withStorage(this.storage);

  Future<void> registerUser(User user) async {
    await storage.saveUser(user.toJson());
  }

  Future<User?> getUser() async {
    final data = await storage.getUser();
    return data != null ? User.fromJson(data) : null;
  }

  Future<bool> loginUser(String email, String password) async {
    final user = await getUser();
    return user != null && user.email == email && user.password == password;
  }

  Future<void> logout() async {
    await storage.clearUser();
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await storage.updateUserSettings(settings);
  }
}
