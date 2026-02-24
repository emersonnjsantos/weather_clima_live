import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/app_logger.dart';
import '../models/weather_models.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService _apiService;
  // Singleton: evita criar novo objeto Connectivity a cada chamada
  final Connectivity _connectivity = Connectivity();

  WeatherRepository({required WeatherApiService apiService})
      : _apiService = apiService;
  static const String _cacheKeyPrefix = 'weather_cache_';
  static const Duration _cacheExpiration = Duration(minutes: 30);

  // Obtém o clima atual por localização
  Future<WeatherData> getCurrentWeather(
      {double? lat, double? lon, String? cityName}) async {
    log.d('getCurrentWeather: cityName=$cityName, lat=$lat, lon=$lon');

    final connectivity = await _connectivity.checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      final cachedData = await _getCachedWeatherData(cityName ?? '${lat}_$lon');
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Sem conexão com a internet e sem dados em cache');
    }

    try {
      WeatherData weatherData;

      if (lat != null && lon != null) {
        log.d('Fetching weather by coordinates: $lat, $lon');
        weatherData =
            await _apiService.getCurrentWeatherByCoordinates(lat, lon);
      } else if (cityName != null) {
        log.d('Fetching weather by city: $cityName');
        weatherData = await _apiService.getCurrentWeatherByCity(cityName);
        log.d('Weather data received for $cityName: ${weatherData.location}');
      } else {
        try {
          log.d('Tentando obter localização GPS...');
          final position = await _apiService.getCurrentLocation();
          log.d(
              'Localização GPS obtida: ${position.latitude}, ${position.longitude}');
          weatherData = await _apiService.getCurrentWeatherByCoordinates(
            position.latitude,
            position.longitude,
          );
          log.d('Clima carregado para a localização GPS atual');
        } catch (locationError) {
          log.w(
              'Falha ao obter GPS: $locationError. Usando Curitiba como padrão.');
          weatherData = await _apiService.getCurrentWeatherByCity('Curitiba');
        }
      }

      log.d(
          'Cache: hourly=${weatherData.hourlyForecast.length}, daily=${weatherData.dailyForecast.length}');
      await _cacheWeatherData(cityName ?? '${lat}_$lon', weatherData);
      log.i('Weather data successfully loaded and cached');
      return weatherData;
    } catch (e) {
      log.e('Error in getCurrentWeather: $e');
      final cachedData = await _getCachedWeatherData(cityName ?? '${lat}_$lon');
      if (cachedData != null) {
        log.i('Returning cached data as fallback');
        return cachedData;
      }
      log.w('No cached data available, rethrowing error');
      rethrow;
    }
  }

  // Obtém dados de clima para a localização atual (usado pelo provider)
  Future<WeatherData> getWeatherForCurrentLocation() async {
    return getCurrentWeather();
  }

  // Obtém dados de clima por coordenadas (usado pelo provider)
  Future<WeatherData> getWeatherData(double lat, double lon) async {
    return getCurrentWeather(lat: lat, lon: lon);
  }

  // Busca cidades pelo nome (via backend)
  Future<List<CityWeather>> searchCities(String query) async {
    final connectivity = await _connectivity.checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      throw Exception('No internet connection available for search');
    }

    return await _apiService.searchCities(query);
  }

  // ── Cidades favoritas (armazenamento local) ────────────────────────

  static const String _favoritesKey = 'favorite_cities';

  /// Obtém cidades favoritas do armazenamento local.
  Future<List<Map<String, dynamic>>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = prefs.getString(_favoritesKey);
    if (favJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(favJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      log.w('Erro ao ler favoritos locais: $e');
      return [];
    }
  }

  /// Adiciona uma cidade favorita localmente.
  Future<bool> addFavoriteCity({
    required String cityName,
    double lat = 0,
    double lon = 0,
    String countryCode = '',
  }) async {
    try {
      final favorites = await getFavoriteCities();

      // Evita duplicatas
      if (favorites.any((c) => c['city_name'] == cityName)) {
        return true;
      }

      favorites.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'city_name': cityName,
        'lat': lat,
        'lon': lon,
        'country_code': countryCode,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoritesKey, jsonEncode(favorites));
      return true;
    } catch (e) {
      log.e('Erro ao adicionar favorito: $e');
      return false;
    }
  }

  /// Remove uma cidade favorita localmente.
  Future<bool> removeFavoriteCity(String id) async {
    try {
      final favorites = await getFavoriteCities();
      favorites.removeWhere((c) => c['id'] == id || c['city_name'] == id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoritesKey, jsonEncode(favorites));
      return true;
    } catch (e) {
      log.e('Erro ao remover favorito: $e');
      return false;
    }
  }

  /// Verifica se uma cidade é favorita.
  Future<bool> isFavoriteCity(String cityName) async {
    final cities = await getFavoriteCities();
    return cities.any((c) => c['city_name'] == cityName);
  }

  /// Obtém o clima para as cidades favoritas em paralelo.
  Future<List<CityWeather>> getFavoriteCitiesWeather() async {
    final favoriteCities = await getFavoriteCities();

    // Future.wait paraleliza as N chamadas em vez de aguardar uma por uma
    final results = await Future.wait(
      favoriteCities.map((city) async {
        final lat = (city['lat'] as num?)?.toDouble() ?? 0;
        final lon = (city['lon'] as num?)?.toDouble() ?? 0;
        final name = city['city_name'] as String? ?? '';
        try {
          final WeatherData weatherData;
          if (lat != 0 && lon != 0) {
            weatherData = await getCurrentWeather(lat: lat, lon: lon);
          } else {
            weatherData = await getCurrentWeather(cityName: name);
          }
          return CityWeather(
            name: weatherData.location.isNotEmpty ? weatherData.location : name,
            country: city['country_code'] ?? '',
            lat: lat,
            lon: lon,
            temperature: weatherData.temperature,
            condition: weatherData.condition,
            icon: weatherData.icon,
          );
        } catch (e) {
          log.w('Erro ao obter clima para favorito $name: $e');
          return null;
        }
      }),
    );

    final List<CityWeather> citiesWeather =
        results.whereType<CityWeather>().toList();

    return citiesWeather;
  }

  // ── Gerenciamento de cache local (offline fallback) ────────────────

  Future<void> _cacheWeatherData(String key, WeatherData data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': {
        'temperature': data.temperature,
        'feelsLike': data.feelsLike,
        'condition': data.condition,
        'description': data.description,
        'icon': data.icon,
        'weatherId': data.weatherId,
        'location': data.location,
        'humidity': data.humidity,
        'windSpeed': data.windSpeed,
        'windDirection': data.windDirection,
        'pressure': data.pressure,
        'visibility': data.visibility,
        'uvIndex': data.uvIndex,
        'sunrise': data.sunrise.millisecondsSinceEpoch,
        'sunset': data.sunset.millisecondsSinceEpoch,
        'lastUpdated': data.lastUpdated.millisecondsSinceEpoch,
        'hourlyForecast': data.hourlyForecast
            .map((h) => {
                  'dt': h.time.millisecondsSinceEpoch ~/ 1000,
                  'temp': h.temperature,
                  'feels_like': h.feelsLike,
                  'pop': h.precipitation / 100,
                  'weather': [
                    {
                      'icon': h.icon,
                      'id': h.weatherId,
                      'description': h.description
                    }
                  ],
                  'wind_speed': h.windSpeed,
                  'wind_gust': h.windGust,
                  'wind_deg': h.windDirection,
                })
            .toList(),
        'dailyForecast': data.dailyForecast
            .map((d) => {
                  'dt': d.date.millisecondsSinceEpoch ~/ 1000,
                  'temp': {'max': d.high, 'min': d.low},
                  'pop': d.precipitation / 100,
                  'weather': [
                    {
                      'icon': d.icon,
                      'id': d.weatherId,
                      'description': d.description
                    }
                  ],
                })
            .toList(),
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await prefs.setString('$_cacheKeyPrefix$key', jsonEncode(cacheData));
  }

  Future<WeatherData?> _getCachedWeatherData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('$_cacheKeyPrefix$key');

    if (cachedJson == null) return null;

    try {
      final cacheData = jsonDecode(cachedJson);
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);

      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        return null;
      }

      final data = cacheData['data'];

      List<HourlyWeather> hourlyForecast = [];
      List<DailyWeather> dailyForecast = [];

      if (data['hourlyForecast'] != null) {
        hourlyForecast = (data['hourlyForecast'] as List)
            .map((item) => HourlyWeather.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (data['dailyForecast'] != null) {
        dailyForecast = (data['dailyForecast'] as List)
            .map((item) => DailyWeather.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return WeatherData(
        temperature: data['temperature'].toDouble(),
        feelsLike: data['feelsLike'].toDouble(),
        condition: data['condition'],
        description: data['description'],
        icon: data['icon'],
        weatherId: data['weatherId'] ?? 800,
        location: data['location'],
        humidity: data['humidity'],
        windSpeed: data['windSpeed'].toDouble(),
        windDirection: data['windDirection'],
        pressure: data['pressure'].toDouble(),
        visibility: data['visibility'].toDouble(),
        uvIndex: data['uvIndex'],
        sunrise: DateTime.fromMillisecondsSinceEpoch(data['sunrise']),
        sunset: DateTime.fromMillisecondsSinceEpoch(data['sunset']),
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(data['lastUpdated']),
        hourlyForecast: hourlyForecast,
        dailyForecast: dailyForecast,
      );
    } catch (e) {
      return null;
    }
  }

  // Limpa todos os dados em cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith(_cacheKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  // Obtém a URL do ícone de clima
  String getWeatherIconUrl(String iconCode) {
    return _apiService.getWeatherIconUrl(iconCode);
  }
}
