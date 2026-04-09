import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import '../services/auth_service.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/create_order_usecase.dart';
import '../../features/orders/domain/usecases/get_orders_usecase.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';

import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core services
  final sharedPreferences = await SharedPreferences.getInstance();
  final secureStorage = FlutterSecureStorage();
  
  // Dio client
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: AppConfig.timeout,
    receiveTimeout: AppConfig.timeout,
    headers: {'Content-Type': 'application/json'},
  ));
  
  // Register core services
  getIt
    ..registerLazySingleton(() => sharedPreferences)
    ..registerLazySingleton(() => secureStorage)
    ..registerLazySingleton(() => dio)
    ..registerLazySingleton(() => ApiService(dio: getIt()))
    ..registerLazySingleton(() => StorageService())
    ..registerLazySingleton(() => NotificationService())
    ..registerLazySingleton(() => LocationService())
    ..registerLazySingleton(() => CameraService())
    ..registerLazySingleton(() => AuthService());
  
  // Data sources
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiService: getIt()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(storageService: getIt()),
    )
    ..registerLazySingleton<OrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(apiService: getIt()),
    )
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(apiService: getIt()),
    );
  
  // Repositories
  getIt
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
      ),
    )
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDataSource: getIt()),
    );
  
  // Use cases
  getIt
    ..registerLazySingleton(() => LoginUseCase(authRepository: getIt()))
    ..registerLazySingleton(() => RegisterUseCase(authRepository: getIt()))
    ..registerLazySingleton(() => LogoutUseCase(authRepository: getIt()))
    ..registerLazySingleton(() => CreateOrderUseCase(orderRepository: getIt()))
    ..registerLazySingleton(() => GetOrdersUseCase(orderRepository: getIt()))
    ..registerLazySingleton(() => GetNotificationsUseCase(notificationRepository: getIt()));
}
