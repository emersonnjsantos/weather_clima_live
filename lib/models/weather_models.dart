class WeatherData {
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final String icon;
  final int weatherId; // Código numérico da API (ex: 800, 501, etc)
  final String location;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double visibility;
  final int uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime lastUpdated;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.icon,
    required this.weatherId,
    required this.location,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.lastUpdated,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // Suporta tanto o formato do backend Go quanto o formato direto da API OpenWeatherMap
    final bool isBackendFormat = json.containsKey('current');

    // Parse hourly and daily forecasts if available
    List<HourlyWeather> hourlyForecast = [];
    List<DailyWeather> dailyForecast = [];

    if (json.containsKey('hourly') && json['hourly'] is List) {
      print(
          'DEBUG: Parsing hourly forecast, count: ${(json['hourly'] as List).length}');
      try {
        hourlyForecast = (json['hourly'] as List)
            .map((item) => HourlyWeather.fromJson(item))
            .toList();
        print(
            'DEBUG: Successfully parsed ${hourlyForecast.length} hourly items');
      } catch (e) {
        print('DEBUG: Error parsing hourly: $e');
      }
    }

    if (json.containsKey('daily') && json['daily'] is List) {
      print(
          'DEBUG: Parsing daily forecast, count: ${(json['daily'] as List).length}');
      try {
        dailyForecast = (json['daily'] as List)
            .map((item) => DailyWeather.fromJson(item))
            .toList();
        print('DEBUG: Successfully parsed ${dailyForecast.length} daily items');
      } catch (e) {
        print('DEBUG: Error parsing daily: $e');
      }
    }

    if (isBackendFormat) {
      // Formato do backend Go
      final current = json['current'];
      return WeatherData(
        temperature: current['temp'].toDouble(),
        feelsLike: current['feels_like'].toDouble(),
        condition: current['weather'][0]['main'],
        description: current['weather'][0]['description'],
        icon: current['weather'][0]['icon'],
        weatherId: current['weather'][0]['id'],
        location: json['timezone'], // Backend usa timezone para nome da cidade
        humidity: current['humidity'],
        windSpeed: current['wind_speed'].toDouble(),
        windDirection: current['wind_deg'],
        pressure: current['pressure'].toDouble(),
        visibility: current['visibility'].toDouble() / 1000, // Convert to km
        uvIndex: (current['uvi'] ?? 0).toInt(),
        sunrise: DateTime.fromMillisecondsSinceEpoch(current['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(current['sunset'] * 1000),
        lastUpdated: DateTime.now(),
        hourlyForecast: hourlyForecast,
        dailyForecast: dailyForecast,
      );
    } else {
      // Formato direto da API OpenWeatherMap 2.5
      return WeatherData(
        temperature: json['main']['temp'].toDouble(),
        feelsLike: json['main']['feels_like'].toDouble(),
        condition: json['weather'][0]['main'],
        description: json['weather'][0]['description'],
        icon: json['weather'][0]['icon'],
        weatherId: json['weather'][0]['id'],
        location: json['name'],
        humidity: json['main']['humidity'],
        windSpeed: json['wind']['speed'].toDouble(),
        windDirection: json['wind']['deg'],
        pressure: json['main']['pressure'].toDouble(),
        visibility: json['visibility'].toDouble() / 1000, // Convert to km
        uvIndex: 0, // Will be fetched separately
        sunrise:
            DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
        sunset:
            DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
        lastUpdated: DateTime.now(),
        hourlyForecast: hourlyForecast,
        dailyForecast: dailyForecast,
      );
    }
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final int precipitation;
  final String icon;
  final int weatherId; // ID numérico da API
  final String description;
  final double windSpeed; // Velocidade do vento em m/s
  final double windGust; // Rajadas de vento em m/s
  final int windDirection; // Direção do vento em graus

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.precipitation,
    required this.icon,
    required this.weatherId,
    required this.description,
    required this.windSpeed,
    required this.windGust,
    required this.windDirection,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    // Suporta tanto a estrutura da API direta quanto do backend
    final temp = json['temp'] ?? json['main']?['temp'];
    final feelsLike = json['feels_like'] ?? json['main']?['feels_like'];
    final windSpeed = json['wind_speed'] ?? json['wind']?['speed'];
    final windGust = json['wind_gust'] ?? json['wind']?['gust'] ?? windSpeed;
    final windDeg = json['wind_deg'] ?? json['wind']?['deg'];

    return HourlyWeather(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (temp ?? 0).toDouble(),
      feelsLike: (feelsLike ?? 0).toDouble(),
      precipitation: ((json['pop'] ?? 0) * 100).toInt(),
      icon: json['weather'][0]['icon'],
      weatherId: json['weather'][0]['id'],
      description: json['weather'][0]['description'],
      windSpeed: (windSpeed ?? 0).toDouble(),
      windGust: (windGust ?? 0).toDouble(),
      windDirection: windDeg ?? 0,
    );
  }
}

class DailyWeather {
  final DateTime date;
  final double high;
  final double low;
  final int precipitation;
  final String icon;
  final int weatherId; // ID numérico da API
  final String description;

  DailyWeather({
    required this.date,
    required this.high,
    required this.low,
    required this.precipitation,
    required this.icon,
    required this.weatherId,
    required this.description,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    // Suporta tanto a estrutura da API direta quanto do backend
    final tempData = json['temp'];
    final high = tempData is Map ? tempData['max'] : tempData;
    final low = tempData is Map ? tempData['min'] : tempData;

    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      high: (high ?? 0).toDouble(),
      low: (low ?? 0).toDouble(),
      precipitation: ((json['pop'] ?? 0) * 100).toInt(),
      icon: json['weather'][0]['icon'],
      weatherId: json['weather'][0]['id'],
      description: json['weather'][0]['description'],
    );
  }
}

class CityWeather {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final double temperature;
  final String condition;
  final String icon;

  CityWeather({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temperature,
    required this.condition,
    required this.icon,
  });

  factory CityWeather.fromJson(Map<String, dynamic> json) {
    return CityWeather(
      name: json['name'],
      country: json['sys']['country'],
      lat: json['coord']['lat'].toDouble(),
      lon: json['coord']['lon'].toDouble(),
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}

class WeatherAlert {
  final String title;
  final String description;
  final String severity;
  final DateTime start;
  final DateTime end;

  WeatherAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.start,
    required this.end,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      title: json['event'],
      description: json['description'],
      severity: json['severity'],
      start: DateTime.fromMillisecondsSinceEpoch(json['start'] * 1000),
      end: DateTime.fromMillisecondsSinceEpoch(json['end'] * 1000),
    );
  }
}
