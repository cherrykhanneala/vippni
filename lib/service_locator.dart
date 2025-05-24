import 'package:get_it/get_it.dart';
import 'package:vipnni/core/auth_service.dart';
import 'package:vipnni/services/order_service.dart';
import 'package:vipnni/services/cache_service.dart';
import 'package:vipnni/services/logging_service.dart';
import 'package:vipnni/providers/order_provider.dart';
import 'package:vipnni/services/connectivity_service.dart';
import 'package:vipnni/repositories/stock_repository.dart';
import 'package:vipnni/providers/product_provider.dart';
// ...import any other services, providers, or repositories as needed...

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register services
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<OrderService>(() => OrderService());
  locator.registerLazySingleton<CacheService>(() => CacheService());
  locator.registerLazySingleton<LoggingService>(() => LoggingService());
  locator.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Register repositories
  locator.registerLazySingleton<StockRepository>(() => StockRepository());
  
  // Register providers
  locator.registerFactory<OrderProvider>(() => OrderProvider());
  locator.registerFactory<ProductProvider>(() => ProductProvider());
  
  // ...register other dependencies as needed...
}