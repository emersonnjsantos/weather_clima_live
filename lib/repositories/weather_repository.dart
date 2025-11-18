import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/weather_models.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService _apiService = WeatherApiService();
  static const String _cacheKeyPrefix = 'weather_cache_';
  static const String _favoriteCitiesKey = 'favorite_cities';
  static const Duration _cacheExpiration = Duration(minutes: 30);

  // Obtém o clima atual por localização
  Future<WeatherData> getCurrentWeather(
      {double? lat, double? lon, String? cityName}) async {
    print('===== getCurrentWeather called =====');
    print('cityName: $cityName, lat: $lat, lon: $lon');

    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      // Tenta obter dados do cache
      final cachedData = await _getCachedWeatherData(cityName ?? '${lat}_$lon');
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Sem conexão com a internet e sem dados em cache');
    }

    try {
      WeatherData weatherData;

      if (lat != null && lon != null) {
        print('Fetching weather by coordinates: $lat, $lon');
        weatherData =
            await _apiService.getCurrentWeatherByCoordinates(lat, lon);
      } else if (cityName != null) {
        print('Fetching weather by city: $cityName');
        weatherData = await _apiService.getCurrentWeatherByCity(cityName);
        print('Weather data received for $cityName: ${weatherData.location}');
      } else {
        // Tentar obter localização atual do GPS com fallback para Curitiba
        try {
          print('Tentando obter localização GPS...');
          final position = await _apiService.getCurrentLocation();
          print(
              'Localização GPS obtida: ${position.latitude}, ${position.longitude}');
          weatherData = await _apiService.getCurrentWeatherByCoordinates(
            position.latitude,
            position.longitude,
          );
          print('Clima carregado para a localização GPS atual');
        } catch (locationError) {
          // Se falhar ao obter GPS (permissão negada, GPS desligado, etc), usar Curitiba como padrão
          print('Falha ao obter GPS: $locationError');
          print('Usando Curitiba como cidade padrão');
          weatherData = await _apiService.getCurrentWeatherByCity('Curitiba');
        }
      }

      // Armazena os dados no cache
      print(
          'DEBUG REPO: Before cache - hourly: ${weatherData.hourlyForecast.length}, daily: ${weatherData.dailyForecast.length}');
      await _cacheWeatherData(cityName ?? '${lat}_$lon', weatherData);
      print(
          'DEBUG REPO: After cache - hourly: ${weatherData.hourlyForecast.length}, daily: ${weatherData.dailyForecast.length}');

      print('Weather data successfully loaded and cached');
      return weatherData;
    } catch (e) {
      print('ERROR in getCurrentWeather: $e');
      // Tenta obter dados do cache como fallback
      final cachedData = await _getCachedWeatherData(cityName ?? '${lat}_$lon');
      if (cachedData != null) {
        print('Returning cached data as fallback');
        return cachedData;
      }
      print('No cached data available, rethrowing error');
      rethrow;
    }
  }

  // Busca cidades
  Future<List<CityWeather>> searchCities(String query) async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      throw Exception('No internet connection available for search');
    }

    return await _apiService.searchCities(query);
  }

  // Favorite cities management
  Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getStringList(_favoriteCitiesKey) ?? [];
    return citiesJson;
  }

  Future<void> addFavoriteCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = await getFavoriteCities();

    if (!cities.contains(cityName)) {
      cities.add(cityName);
      await prefs.setStringList(_favoriteCitiesKey, cities);
    }
  }

  Future<void> removeFavoriteCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = await getFavoriteCities();
    cities.remove(cityName);
    await prefs.setStringList(_favoriteCitiesKey, cities);
  }

  Future<bool> isFavoriteCity(String cityName) async {
    final cities = await getFavoriteCities();
    return cities.contains(cityName);
  }

  // Obtém o clima para várias cidades favoritas
  Future<List<CityWeather>> getFavoriteCitiesWeather() async {
    final favoriteCities = await getFavoriteCities();
    final List<CityWeather> citiesWeather = [];

    for (String cityName in favoriteCities) {
      try {
        final weatherData = await getCurrentWeather(cityName: cityName);
        citiesWeather.add(CityWeather(
          name: weatherData.location,
          country: '', // Will be filled from API response
          lat: 0, // Will be filled from API response
          lon: 0, // Will be filled from API response
          temperature: weatherData.temperature,
          condition: weatherData.condition,
          icon: weatherData.icon,
        ));
      } catch (e) {
        // Pula cidades que falharam ao carregar
        continue;
      }
    }

    return citiesWeather;
  }

  // Gerenciamento de cache
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

      // Verifica se o cache expirou
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        return null;
      }

      final data = cacheData['data'];

      // Parse hourly and daily from cache
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
        weatherId: data['weatherId'] ?? 800, // Default to clear sky
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
