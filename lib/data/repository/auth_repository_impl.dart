import 'package:crypto_desctop/data/datasource/auth_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/user_model.dart';
import 'package:crypto_desctop/domain/repository/auth_repo.dart';

/// Реализация Auth Repository
/// Координирует работу с удаленной аутентификацией
///
/// Flow:
/// 1. Пользователь логинится через Supabase
/// 2. Получаем User данные из Supabase
/// 3. Данные юзера получаются всегда из сети (не кешируются локально)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<User> register(
    String email,
    String password,
    String displayName,
  ) async {
    return await remoteDataSource.register(
      email,
      password,
      displayName,
    );
  }

  @override
  Future<User> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
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
