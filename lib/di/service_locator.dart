import 'package:crypto_desctop/data/datasource/coin_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_local_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/user_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/user_local_datasource_impl.dart';
import 'package:crypto_desctop/data/repository/coin_repository_impl.dart';
import 'package:crypto_desctop/data/repository/user_repository_impl.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/domain/repository/user_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

final getIt = GetIt.instance;

void setupServiceLocator(Isar isar) {
  // reg Isar
  getIt.registerSingleton<Isar>(isar);

  // ======== COIN ========
  // reg CoinLocalDatasource
  getIt.registerSingleton<CoinLocalDatasource>(
    CoinLocalDatasourceImpl(getIt<Isar>()),
  );

  // reg CoinRemoteDatasource
  getIt.registerSingleton<CoinRemoteDatasource>(
    CoinRemoteDatasourceImpl(),
  );

  // reg CoinRepository
  getIt.registerSingleton<CoinRepo>(
    CoinRepositoryImpl(
      localDatasource: getIt<CoinLocalDatasource>(),
      remoteDatasource: getIt<CoinRemoteDatasource>(),
    ),
  );

  // ======== USER ========
  // reg UserLocalDatasource
  getIt.registerSingleton<UserLocalDataSource>(
    UserLocalDataSourceImpl(getIt<Isar>()),
  );

  // reg UserRepository
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(
      localDataSource: getIt<UserLocalDataSource>(),
    ),
  );
}