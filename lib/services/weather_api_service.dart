import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../core/app_logger.dart';
import '../models/weather_models.dart';

/// Serviço que chama a OpenWeatherMap API diretamente (sem backend).
///
/// Usa as APIs:
///   - /data/2.5/weather  → clima atual
///   - /data/2.5/forecast → previsão 5 dias / 3 horas
///   - /geo/1.0/direct    → geocodificação (busca de cidades)
class WeatherApiService {
  static const String _owmBaseUrl = 'https://api.openweathermap.org';

  final Dio _dio = Dio();
  String? _apiKey;

  WeatherApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (object) {
        if (!kReleaseMode) {
          debugPrint('[OWM] $object');
        }
      },
    ));
  }

  /// Carrega a API key do env.json (lazy load, uma vez só).
  Future<void> _ensureApiKey() async {
    if (_apiKey != null) return;
    final envJson = await rootBundle.loadString('env.json');
    final env = json.decode(envJson);
    _apiKey = env['OPENWEATHER_API_KEY'];
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OPENWEATHER_API_KEY não configurada em env.json');
    }
  }

  // ── Clima atual por coordenadas ─────────────────────────────────────

  Future<WeatherData> getCurrentWeatherByCoordinates(
      double lat, double lon) async {
    await _ensureApiKey();

    try {
      // 1. Buscar clima atual (/data/2.5/weather)
      final currentResponse = await _dio.get(
        '$_owmBaseUrl/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'pt_br',
        },
      );

      if (currentResponse.statusCode != 200) {
        throw Exception(
            'Erro ao buscar clima: status ${currentResponse.statusCode}');
      }

      final currentData = currentResponse.data as Map<String, dynamic>;

      // 2. Buscar previsão 5 dias (/data/2.5/forecast)
      List<HourlyWeather> hourlyForecast = [];
      List<DailyWeather> dailyForecast = [];

      try {
        final forecastResponse = await _dio.get(
          '$_owmBaseUrl/data/2.5/forecast',
          queryParameters: {
            'lat': lat,
            'lon': lon,
            'appid': _apiKey,
            'units': 'metric',
            'lang': 'pt_br',
          },
        );

        if (forecastResponse.statusCode == 200) {
          final forecastData = forecastResponse.data as Map<String, dynamic>;
          final List<dynamic> forecastList = forecastData['list'] ?? [];

          // Converte primeiros 8 itens (24h) para previsão horária
          hourlyForecast = _convertToHourly(forecastList);

          // Agrupa por dia para previsão diária
          dailyForecast = _convertToDaily(forecastList);
        }
      } catch (e) {
        log.w('Previsão não disponível, usando apenas clima atual: $e');
      }

      // 3. Monta o WeatherData final
      final weather = currentData['weather'][0];
      return WeatherData(
        temperature: (currentData['main']['temp'] as num).toDouble(),
        feelsLike: (currentData['main']['feels_like'] as num).toDouble(),
        condition: weather['main'],
        description: weather['description'],
        icon: weather['icon'],
        weatherId: weather['id'],
        location: currentData['name'] ?? '',
        humidity: currentData['main']['humidity'],
        windSpeed: (currentData['wind']['speed'] as num).toDouble(),
        windDirection: currentData['wind']['deg'] ?? 0,
        pressure: (currentData['main']['pressure'] as num).toDouble(),
        visibility: (currentData['visibility'] as num).toDouble() / 1000, // km
        uvIndex: 0, // API 2.5 gratuita não fornece UV
        sunrise: DateTime.fromMillisecondsSinceEpoch(
            currentData['sys']['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(
            currentData['sys']['sunset'] * 1000),
        lastUpdated: DateTime.now(),
        hourlyForecast: hourlyForecast,
        dailyForecast: dailyForecast,
      );
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar clima: $e');
    }
  }

  // ── Clima atual por nome da cidade ──────────────────────────────────

  Future<WeatherData> getCurrentWeatherByCity(String cityName) async {
    try {
      final cities = await searchCities(cityName);
      if (cities.isEmpty) {
        throw Exception('Cidade não encontrada: $cityName');
      }
      final city = cities.first;
      return await getCurrentWeatherByCoordinates(city.lat, city.lon);
    } catch (e) {
      throw Exception('Erro ao obter clima por cidade: $e');
    }
  }

  // ── Busca de cidades (Geocoding API) ────────────────────────────────

  Future<List<CityWeather>> searchCities(String query) async {
    await _ensureApiKey();

    try {
      final response = await _dio.get(
        '$_owmBaseUrl/geo/1.0/direct',
        queryParameters: {
          'q': query,
          'limit': 5,
          'appid': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;
        List<CityWeather> cities = [];

        int maxResults = results.length > 5 ? 5 : results.length;

        for (var i = 0; i < maxResults; i++) {
          final geo = results[i];
          try {
            WeatherData weatherData = await getCurrentWeatherByCoordinates(
                (geo['lat'] as num).toDouble(), (geo['lon'] as num).toDouble());

            cities.add(CityWeather(
              name: geo['name'] ?? query,
              country: geo['country'] ?? '',
              lat: (geo['lat'] as num).toDouble(),
              lon: (geo['lon'] as num).toDouble(),
              temperature: weatherData.temperature,
              condition: weatherData.condition,
              icon: weatherData.icon,
            ));
          } catch (e) {
            log.w('Erro ao buscar clima para geocode result $i: $e');
            continue;
          }
        }

        return cities;
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Erro de conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao buscar cidade: $e');
    }
  }

  // ── Ícone de clima ──────────────────────────────────────────────────

  String getWeatherIconUrl(String iconCode, {String size = '4x'}) {
    return 'https://openweathermap.org/img/wn/$iconCode@$size.png';
  }

  // ── Localização GPS ─────────────────────────────────────────────────

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'GPS desabilitado. Por favor, ative a localização nas configurações do dispositivo.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
            'Permissão de localização negada. Por favor, permita o acesso à localização nas configurações do app.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permissão de localização negada permanentemente. Por favor, ative a permissão de localização nas configurações do dispositivo.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
    } catch (e) {
      log.w(
          'Falha ao obter localização com alta precisão, tentando com precisão média...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      );
    }
  }

  // ── Conversão de previsão (replica lógica do backend Go) ────────────

  /// Converte os primeiros 8 itens (24h) para previsão horária.
  List<HourlyWeather> _convertToHourly(List<dynamic> forecastList) {
    int count = forecastList.length > 8 ? 8 : forecastList.length;

    return forecastList.take(count).map((item) {
      final map = item as Map<String, dynamic>;
      final weather = map['weather'][0];
      return HourlyWeather(
        time: DateTime.fromMillisecondsSinceEpoch(map['dt'] * 1000),
        temperature: (map['main']['temp'] as num).toDouble(),
        feelsLike: (map['main']['feels_like'] as num).toDouble(),
        precipitation: ((map['pop'] ?? 0) * 100).toInt(),
        icon: weather['icon'],
        weatherId: weather['id'],
        description: weather['description'],
        windSpeed: (map['wind']['speed'] as num).toDouble(),
        windGust: (map['wind']['gust'] as num?)?.toDouble() ??
            (map['wind']['speed'] as num).toDouble(),
        windDirection: map['wind']['deg'] ?? 0,
      );
    }).toList();
  }

  /// Agrupa os itens por dia para criar previsão diária.
  List<DailyWeather> _convertToDaily(List<dynamic> forecastList) {
    // Agrupa por data (YYYY-MM-DD)
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final List<String> orderedDates = [];

    for (var item in forecastList) {
      final map = item as Map<String, dynamic>;
      final dt = DateTime.fromMillisecondsSinceEpoch(map['dt'] * 1000);
      final dateKey =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
        orderedDates.add(dateKey);
      }
      grouped[dateKey]!.add(map);
    }

    // Limita a 6 dias
    int maxDays = orderedDates.length > 6 ? 6 : orderedDates.length;

    return orderedDates
        .take(maxDays)
        .map((dateKey) {
          final dayItems = grouped[dateKey]!;
          if (dayItems.isEmpty) return null;

          // Usa o item do meio como representativo
          final representative = dayItems[dayItems.length ~/ 2];
          double minTemp = (dayItems[0]['main']['temp_min'] as num).toDouble();
          double maxTemp = (dayItems[0]['main']['temp_max'] as num).toDouble();
          double pop = (dayItems[0]['pop'] as num?)?.toDouble() ?? 0;

          for (var item in dayItems) {
            final tempMin = (item['main']['temp_min'] as num).toDouble();
            final tempMax = (item['main']['temp_max'] as num).toDouble();
            final itemPop = (item['pop'] as num?)?.toDouble() ?? 0;

            if (tempMin < minTemp) minTemp = tempMin;
            if (tempMax > maxTemp) maxTemp = tempMax;
            if (itemPop > pop) pop = itemPop;
          }

          final weather = representative['weather'][0];
          return DailyWeather(
            date: DateTime.fromMillisecondsSinceEpoch(
                representative['dt'] * 1000),
            high: maxTemp,
            low: minTemp,
            precipitation: (pop * 100).toInt(),
            icon: weather['icon'],
            weatherId: weather['id'],
            description: weather['description'],
          );
        })
        .whereType<DailyWeather>()
        .toList();
  }
}
