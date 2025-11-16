import 'package:crypto_desctop/domain/models/user_model.dart';

/// Firebase Auth Repository
abstract class AuthRepository {
  /// Регистрация нового пользователя
  Future<User> register(String email, String password, String displayName);

  /// Логин пользователя
  Future<User> login(String email, String password);

  /// Выход из системы
  Future<void> logout();

  /// Проверить авторизован ли пользователь
  Future<bool> isUserLoggedIn();

  /// Получить текущего авторизованного пользователя
  Future<User?> getCurrentUser();

  /// Получить текущий Supabase UID
  Future<String?> getCurrentUserId();
}
