import 'package:crypto_desctop/data/datasource/user_local_datasource.dart';
import 'package:crypto_desctop/data/models/isar_user_model.dart';
import 'package:crypto_desctop/domain/models/user_model.dart';
import 'package:isar/isar.dart';

/// Реализация локального хранилища User через Isar
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Isar isar;

  UserLocalDataSourceImpl(this.isar);

  @override
  Future<void> saveUser(User user) async {
    final isarUser = IsarUser.fromDomain(user);
    await isar.writeTxn(() async {
      await isar.isarUsers.put(isarUser);
    });
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final isarUser = await isar.isarUsers
        .filter()
        .emailEqualTo(email)
        .findFirst();

    return isarUser?.toDomain();
  }

  @override
  Future<User?> getUserById(String userId) async {
    final isarUser = await isar.isarUsers
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    return isarUser?.toDomain();
  }

  @override
  Future<List<User>> getAllUsers() async {
    final isarUsers = await isar.isarUsers.where().findAll();
    return isarUsers.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> deleteUser(String userId) async {
    final isarUser = await isar.isarUsers
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    if (isarUser != null) {
      await isar.writeTxn(() async {
        await isar.isarUsers.delete(isarUser.id);
      });
    }
  }

  @override
  Future<bool> hasAnyUser() async {
    final count = await isar.isarUsers.count();
    return count > 0;
  }
}
