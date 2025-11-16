import 'package:crypto_desctop/domain/models/user_model.dart';

/// Интерфейс Firebase Authentication Data Source
abstract class AuthRemoteDataSource {
  /// Регистрация нового пользователя в Firebase
  Future<User> register(String email, String password, String displayName);

  /// Логин в Firebase
  Future<User> login(String email, String password);

  /// Выход из Firebase
  Future<void> logout();

  /// Получить текущего авторизованного пользователя
  Future<User?> getCurrentUser();

  /// Проверить, авторизован ли пользователь
  Future<bool> isUserLoggedIn();

  /// Получить текущий Firebase UID
  Future<String?> getCurrentUserId();
}
