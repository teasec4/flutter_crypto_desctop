import 'package:crypto_desctop/data/datasource/auth_remote_datasource.dart';
import 'package:crypto_desctop/data/datasource/user_local_datasource.dart';
import 'package:crypto_desctop/domain/models/user_model.dart';
import 'package:crypto_desctop/domain/repository/auth_repo.dart';

/// Реализация Auth Repository
/// Координирует работу между Firebase (remote) и Isar (local)
///
/// Flow:
/// 1. Пользователь логинится через Firebase
/// 2. Получаем User данные из Firebase
/// 3. Сохраняем email и user info локально в Isar
/// 4. При следующем запуске - проверяем Isar БД по email
/// 5. Ассеты привязаны к email в Isar
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> register(
    String email,
    String password,
    String displayName,
  ) async {
    final remoteDbUser = await remoteDataSource.register(
      email,
      password,
      displayName,
    );
    await localDataSource.saveUser(remoteDbUser);
    return remoteDbUser;
  }

  @override
  Future<User> login(String email, String password) async {
    final remoteDbUser = await remoteDataSource.login(email, password);
    await localDataSource.saveUser(remoteDbUser);
    return remoteDbUser;
  }

  @override
  Future<void> logout() async {
    // Get current user before logout to delete from local storage
    final currentUser = await remoteDataSource.getCurrentUser();

    // Sign out from Firebase
    await remoteDataSource.logout();

    // Delete user from local storage if exists
    if (currentUser != null) {
      await localDataSource.deleteUser(currentUser.id);
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return await remoteDataSource.isUserLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }
}
