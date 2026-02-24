import 'package:get_it/get_it.dart';
import 'package:weatherpro/services/weather_api_service.dart';
import 'package:weatherpro/repositories/weather_repository.dart';

final getIt = GetIt.instance;

/// Inicializa o Service Locator com todas as dependências do app.
void setupServiceLocator() {
  // Serviços
  getIt.registerLazySingleton<WeatherApiService>(() => WeatherApiService());

  // Repositórios
  getIt.registerLazySingleton<WeatherRepository>(
    () => WeatherRepository(apiService: getIt<WeatherApiService>()),
  );
}
