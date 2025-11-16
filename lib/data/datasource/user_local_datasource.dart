import 'package:crypto_desctop/domain/models/user_model.dart';

/// Интерфейс локального хранилища User
/// Описывает что может делать локальное хранилище
abstract class UserLocalDataSource {
  /// Сохранить пользователя в Isar
  Future<void> saveUser(User user);

  /// Получить пользователя из Isar по email
  Future<User?> getUserByEmail(String email);

  /// Получить пользователя по ID
  Future<User?> getUserById(String userId);

  /// Получить всех пользователей (для отладки)
  Future<List<User>> getAllUsers();

  /// Удалить пользователя из Isar
  Future<void> deleteUser(String userId);

  /// Проверить, есть ли пользователи в БД
  Future<bool> hasAnyUser();
}
