import 'package:crypto_desctop/domain/models/user_model.dart';

/// Domain интерфейс репозитория User
/// Определяет контракт - что могут делать с пользователем
/// Реализация будет в Data слое
abstract class UserRepository {
  /// Получить текущего авторизованного пользователя
  /// Выбросит исключение если не авторизован
  Future<User> getCurrentUser();

  /// Сохранить пользователя локально
  /// Используется после регистрации или синхронизации
  Future<void> saveUser(User user);

  /// Получить пользователя по email
  Future<User?> getUserByEmail(String email);

  /// Удалить пользователя (выход из системы)
  Future<void> deleteUser(String userId);

  /// Проверить, авторизован ли пользователь
  Future<bool> isUserLoggedIn();
}
