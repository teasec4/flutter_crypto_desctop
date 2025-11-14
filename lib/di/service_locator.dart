import 'package:crypto_desctop/data/datasource/coin_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_local_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource_impl.dart';
import 'package:crypto_desctop/data/repository/coin_repository_impl.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

final getIt = GetIt.instance;

void setupServiceLocator(Isar isar) {
  // Регистрируем Isar как singleton
  getIt.registerSingleton<Isar>(isar);

  // Регистрируем CoinLocalDatasource
  getIt.registerSingleton<CoinLocalDatasource>(
    CoinLocalDatasourceImpl(getIt<Isar>()),
  );

  // Регистрируем CoinRemoteDatasource
  getIt.registerSingleton<CoinRemoteDatasource>(
    CoinRemoteDatasourceImpl(),
  );

  // Регистрируем CoinRepository
  getIt.registerSingleton<CoinRepo>(
    CoinRepositoryImpl(
      localDatasource: getIt<CoinLocalDatasource>(),
      remoteDatasource: getIt<CoinRemoteDatasource>(),
    ),
  );
}