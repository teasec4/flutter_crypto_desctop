import 'package:crypto_desctop/data/datasource/user_local_datasource.dart';
import 'package:crypto_desctop/domain/models/user_model.dart';
import 'package:crypto_desctop/domain/repository/user_repo.dart';

/// Реализация UserRepository
/// Координирует работу с локальным хранилищем
/// Позже здесь добавится работа с Firebase
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<User> getCurrentUser() async {
    // Пока ищет первого пользователя (позже будет session/currentUser)
    final users = await localDataSource.getAllUsers();
    if (users.isEmpty) {
      throw Exception('No user logged in');
    }
    return users.first;
  }

  @override
  Future<void> saveUser(User user) async {
    await localDataSource.saveUser(user);
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    return await localDataSource.getUserByEmail(email);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await localDataSource.deleteUser(userId);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return await localDataSource.hasAnyUser();
  }
}
