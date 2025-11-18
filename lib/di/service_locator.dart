import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_desctop/data/datasource/auth_remote_datasource.dart';
import 'package:crypto_desctop/data/datasource/auth_remote_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/coin_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_local_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/portfolio_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/portfolio_local_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/portfolio_remote_datasource.dart';
import 'package:crypto_desctop/data/datasource/portfolio_remote_datasource_impl.dart';
import 'package:crypto_desctop/data/datasource/user_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/user_local_datasource_impl.dart';
import 'package:crypto_desctop/data/repository/auth_repository_impl.dart';
import 'package:crypto_desctop/data/repository/coin_repository_impl.dart';
import 'package:crypto_desctop/data/repository/portfolio_repository_impl.dart';
import 'package:crypto_desctop/domain/repository/auth_repo.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/domain/repository/portfolio_repo.dart';
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
  getIt.registerSingleton<CoinRemoteDatasource>(CoinRemoteDatasourceImpl());

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

  // ======== AUTH (Supabase) ========
  // reg AuthRemoteDataSource
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(Supabase.instance.client),
  );

  // reg AuthRepository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<UserLocalDataSource>(),
    ),
  );

  // ======== PORTFOLIO ========
  // reg PortfolioLocalDatasource
  getIt.registerSingleton<PortfolioLocalDataSource>(
    PortfolioLocalDataSourceImpl(getIt<Isar>()),
  );

  // reg PortfolioRemoteDataSource
  getIt.registerSingleton<PortfolioRemoteDataSource>(
    PortfolioRemoteDataSourceImpl(Supabase.instance.client),
  );

  // reg PortfolioRepository
  getIt.registerSingleton<PortfolioRepository>(
    PortfolioRepositoryImpl(
      remoteDataSource: getIt<PortfolioRemoteDataSource>(),
      localDataSource: getIt<PortfolioLocalDataSource>(),
    ),
  );

  // ======== CUBITS ========
  // AuthCubit is created in MyApp with PortfolioCubit reference
  // so we don't register it here
}
