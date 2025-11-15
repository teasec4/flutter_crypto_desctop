import 'package:crypto_desctop/domain/models/user_model.dart';
import 'package:isar/isar.dart';

part 'isar_user_model.g.dart';

/// Isar модель User
/// Специфична для локального хранилища
@collection
class IsarUser {
  Id id = Isar.autoIncrement;

  // Domain ID (например, UUID)
  late String userId;
  late String email;
  late String displayName;
  late DateTime createdAt;

  // Метаданные синхронизации (для будущего Firebase)
  late DateTime lastSyncedAt;
  late bool isSyncedWithCloud;

  IsarUser();

  // ------ Domain → Isar ------
  factory IsarUser.fromDomain(User user) {
    return IsarUser()
      ..userId = user.id
      ..email = user.email
      ..displayName = user.displayName
      ..createdAt = user.createdAt
      ..lastSyncedAt = DateTime.now()
      ..isSyncedWithCloud = false;
  }

  // ------ Isar → Domain ------
  User toDomain() {
    return User(
      id: userId,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
    );
  }
}
