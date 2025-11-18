import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Adicionado
import '../models/weather_models.dart';

class WeatherApiService {
  static const String _baseUrl = String.fromEnvironment('BACKEND_URL',
      defaultValue: 'http://localhost:8080' // Default for local development
      );

  final Dio _dio = Dio();

  WeatherApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Adiciona interceptor para logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (object) {
        // Logging apenas em desenvolvimento
        if (!kReleaseMode) {
          debugPrint('[API] $object');
        }
      },
    ));
  }

  // Obtém o clima atual por coordenadas
  Future<WeatherData> getCurrentWeatherByCoordinates(
      double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          // O backend Go lida com 'units' e 'lang'
        },
      );

      if (response.statusCode == 200) {
        final weatherData = WeatherData.fromJson(response.data);

        print(
            'DEBUG SERVICE: Parsed weatherData - hourly: ${weatherData.hourlyForecast.length}, daily: ${weatherData.dailyForecast.length}');

        // Retornar o weatherData já parseado com todas as previsões
        return weatherData;
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Obtém o clima atual pelo nome da cidade
  Future<WeatherData> getCurrentWeatherByCity(String cityName) async {
    try {
      List<Location> locations =
          await GeocodingPlatform.instance!.locationFromAddress(cityName);
      if (locations.isEmpty) {
        throw Exception('Cidade não encontrada através da geocodificação.');
      }
      // Pega a primeira localização encontrada
      Location location = locations.first;
      return await getCurrentWeatherByCoordinates(
          location.latitude, location.longitude);
    } catch (e) {
      throw Exception('Erro ao obter clima por cidade: $e');
    }
  }

  // Busca cidades pelo nome
  Future<List<CityWeather>> searchCities(String query) async {
    try {
      List<Location> locations =
          await GeocodingPlatform.instance!.locationFromAddress(query);
      if (locations.isEmpty) {
        return []; // Nenhuma cidade encontrada
      }

      List<CityWeather> results = [];

      // Limita a 5 resultados para não fazer muitas requisições
      int maxResults = locations.length > 5 ? 5 : locations.length;

      for (var i = 0; i < maxResults; i++) {
        var loc = locations[i];

        try {
          // Faz a geocodificação reversa para obter os detalhes do local
          List<Placemark> placemarks = await GeocodingPlatform.instance!
              .placemarkFromCoordinates(loc.latitude, loc.longitude);

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;

            // Debug para ver quais campos estão preenchidos
            print(
                'DEBUG PLACEMARK: locality=${place.locality}, subAdmin=${place.subAdministrativeArea}, admin=${place.administrativeArea}, country=${place.country}');

            // Busca o clima atual dessa localização
            WeatherData weatherData = await getCurrentWeatherByCoordinates(
                loc.latitude, loc.longitude);

            // Determina o nome da cidade - PRIORIZA Placemark quando disponível
            String cityName;
            if (place.locality != null && place.locality!.isNotEmpty) {
              cityName = place.locality!;
            } else if (place.subAdministrativeArea != null &&
                place.subAdministrativeArea!.isNotEmpty) {
              cityName = place.subAdministrativeArea!;
            } else if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty) {
              cityName = place.administrativeArea!;
            } else if (weatherData.location.isNotEmpty) {
              cityName = weatherData.location;
            } else {
              cityName = query;
            }

            print(
                'DEBUG CITY NAME: Using "${cityName}" (locality="${place.locality}", subAdmin="${place.subAdministrativeArea}", backend="${weatherData.location}")');

            results.add(CityWeather(
              name: cityName,
              country: place.country ?? '',
              lat: loc.latitude,
              lon: loc.longitude,
              temperature: weatherData.temperature,
              condition: weatherData.condition,
              icon: weatherData.icon,
            ));
          }
        } catch (e) {
          // Se falhar para uma cidade específica, continua para a próxima
          print('Erro ao buscar clima para localização $i: $e');
          continue;
        }
      }

      return results;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // City not found, return empty list
      }
      throw Exception('Erro de conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao buscar cidade: $e');
    }
  }

  // Obtém a URL do ícone de clima
  String getWeatherIconUrl(String iconCode, {String size = '4x'}) {
    // Esta URL ainda aponta para o OpenWeatherMap, pois o backend Go não serve ícones.
    return 'https://openweathermap.org/img/wn/$iconCode@$size.png';
  }

  // Obtém a localização atual (ainda usa geolocator diretamente)
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'GPS desabilitado. Por favor, ative a localização nas configurações do dispositivo.');
    }

    // Verifica e solicita permissões
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

    // Tenta obter a localização atual com configurações otimizadas
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
    } catch (e) {
      // Se falhar com alta precisão, tenta com precisão média
      print(
          'Falha ao obter localização com alta precisão, tentando com precisão média...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      );
    }
  }
}
