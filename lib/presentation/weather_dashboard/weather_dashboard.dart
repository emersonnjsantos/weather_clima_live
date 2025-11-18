import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_export.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_drawer.dart';
import './widgets/current_weather_widget.dart';
import './widgets/weather_news_widget.dart';
import './widgets/daily_forecast_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/weather_maps_preview_widget.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final WeatherRepository _weatherRepository = WeatherRepository();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = true;
  String? _error;

  WeatherData? _currentWeather;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeNotifications();
    _loadInitialData();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Clear cache to ensure fresh data
      await _weatherRepository.clearCache();

      // Load current weather
      final weather = await _weatherRepository.getCurrentWeather();

      // Debug: Print weather data
      debugPrint('===== WEATHER DATA LOADED =====');
      debugPrint('Location: ${weather.location}');
      debugPrint('Temperature: ${weather.temperature}°C');
      debugPrint('Condition: ${weather.condition}');
      debugPrint('Hourly Forecast Count: ${weather.hourlyForecast.length}');
      debugPrint('Daily Forecast Count: ${weather.dailyForecast.length}');
      debugPrint('==============================');

      setState(() {
        _currentWeather = weather;
        _isLoading = false;
      });

      // Show weather notification
      await _notificationService.showWeatherNotification(weather);
    } catch (e) {
      final errorMessage = e.toString();
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });

      // Show user-friendly error message
      String displayMessage = "Erro ao carregar dados";
      Color backgroundColor = Colors.orange;

      if (errorMessage.contains('API Key não configurada')) {
        displayMessage =
            "Configure a chave da API do OpenWeatherMap. Veja API_SETUP.md";
        backgroundColor = Colors.red;
      } else if (errorMessage.contains('Sem conexão')) {
        displayMessage = "Sem conexão com a internet";
        backgroundColor = Colors.red;
      } else if (errorMessage.contains('Location services are disabled')) {
        displayMessage =
            "Localização desabilitada. Mostrando dados de São Paulo. Ative o GPS para sua localização.";
        backgroundColor = Colors.orange;
      } else if (errorMessage.contains('Location permissions')) {
        displayMessage =
            "Permissão de localização negada. Mostrando dados de São Paulo.";
        backgroundColor = Colors.orange;
      } else {
        displayMessage = "Erro: ${errorMessage.replaceAll('Exception: ', '')}";
        backgroundColor = Colors.red;
      }

      Fluttertoast.showToast(
        msg: displayMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: backgroundColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _refreshWeatherData() async {
    try {
      // Clear cache to force fresh data
      await _weatherRepository.clearCache();

      // Refresh current weather
      final weather = await _weatherRepository.getCurrentWeather();

      setState(() {
        _currentWeather = weather;
        _error = null;
      });

      // Update weather notification
      await _notificationService.showWeatherNotification(weather);

      Fluttertoast.showToast(
        msg: "Dados atualizados com sucesso!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      final errorMessage = e.toString();

      // Show user-friendly error message
      String displayMessage = "Erro ao atualizar";
      if (errorMessage.contains('API Key não configurada')) {
        displayMessage = "Configure a chave da API. Veja API_SETUP.md";
      } else if (errorMessage.contains('No internet connection')) {
        displayMessage = "Sem conexão com a internet";
      } else {
        displayMessage = "Erro: ${errorMessage.replaceAll('Exception: ', '')}";
      }

      Fluttertoast.showToast(
        msg: displayMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _loadWeatherForCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Clear cache to ensure fresh data
      await _weatherRepository.clearCache();

      // Load weather for the selected city
      final weather = await _weatherRepository.getCurrentWeather(
        cityName: cityName,
      );

      setState(() {
        _currentWeather = weather;
        _isLoading = false;
      });

      // Show weather notification
      await _notificationService.showWeatherNotification(weather);

      Fluttertoast.showToast(
        msg: "Clima carregado para $cityName",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      final errorMessage = e.toString();
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg:
            "Erro ao carregar clima: ${errorMessage.replaceAll('Exception: ', '')}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        drawer: const AppDrawer(),
        body: SafeArea(
          bottom: false, // Permite que o conteúdo vá até a barra de navegação
          child: Column(
            children: [
              // App Bar with Location
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.75.h),
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      return IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.grey[700],
                          size: 28,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    }),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        _currentWeather?.location ?? 'Carregando...',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.grey[700],
                        size: 28,
                      ),
                      onPressed: () async {
                        final cityName =
                            await Navigator.pushNamed(context, '/city-search');
                        if (cityName != null && cityName is String) {
                          _loadWeatherForCity(cityName);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Time and Action Icons Row
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                child: Row(
                  children: [
                    // Time
                    Flexible(
                      child: Text(
                        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${_getDayOfWeek()}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // Action Icons
                    IconButton(
                      icon: Icon(
                        Icons.diamond_outlined,
                        color: Colors.blue[400],
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        Navigator.pushNamed(context, '/premium');
                      },
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.blue[400],
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        // Navega para tela de notícias/comentários
                        Navigator.pushNamed(context, '/news-screen');
                      },
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.blue[400],
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () async {
                        // Compartilhar previsão do tempo atual
                        String shareText;

                        if (_currentWeather != null) {
                          shareText = '🌤️ Previsão do Tempo - ClimaLive\n\n'
                              '📍 ${_currentWeather!.location}\n'
                              '�️ Temperatura: ${_currentWeather!.temperature.round()}°C\n'
                              '🌥️ Condição: ${_currentWeather!.description}\n'
                              '💧 Umidade: ${_currentWeather!.humidity}%\n'
                              '💨 Vento: ${_currentWeather!.windSpeed.round()} km/h\n\n'
                              'Baixe o ClimaLive e fique sempre informado sobre o clima! ☀️';
                        } else {
                          shareText =
                              '🌤️ Confira a previsão do tempo no ClimaLive!\n\n'
                              'Baixe agora e fique sempre informado sobre o clima. ☀️';
                        }

                        try {
                          await Share.share(
                            shareText,
                            subject: 'Previsão do Tempo - ClimaLive',
                          );
                        } catch (e) {
                          debugPrint('Erro ao compartilhar: $e');
                          Fluttertoast.showToast(
                            msg: "Erro ao compartilhar",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      },
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey[700],
                        size: 24,
                      ),
                      offset: Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      onSelected: (value) {
                        switch (value) {
                          case 'notifications':
                            Navigator.pushNamed(
                                context, '/notifications-center');
                            break;
                          case 'customization':
                            Navigator.pushNamed(
                                context, '/advanced_customization');
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'notifications',
                          child: Text(
                            'Ativar notificações',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'customization',
                          child: Text(
                            'Personalização avançada',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red[300],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Erro ao carregar dados',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                ElevatedButton(
                                  onPressed: _loadInitialData,
                                  child: Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refreshWeatherData,
                            child: ListView(
                              padding: EdgeInsets.only(
                                top: 2.h,
                                bottom:
                                    MediaQuery.of(context).padding.bottom + 2.h,
                              ),
                              children: [
                                if (_currentWeather != null)
                                  CurrentWeatherWidget(
                                    weatherData: _convertWeatherDataToMap(
                                        _currentWeather!),
                                  ),
                                // Widget de notícias do clima
                                WeatherNewsWidget(
                                  title:
                                      'Nova frente fria chega ao Brasil nesta semana e traz risco de ...',
                                  subtitle:
                                      'Confira os detalhes da previsão e os impactos esperados na sua região.',
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/news-screen');
                                  },
                                ),
                                SizedBox(height: 3.h),
                                if (_currentWeather != null &&
                                    _currentWeather!.hourlyForecast.isNotEmpty)
                                  HourlyForecastWidget(
                                    hourlyForecast:
                                        _currentWeather!.hourlyForecast,
                                  ),
                                SizedBox(height: 3.h),
                                if (_currentWeather != null &&
                                    _currentWeather!.dailyForecast.isNotEmpty)
                                  DailyForecastWidget(
                                    dailyForecast:
                                        _currentWeather!.dailyForecast,
                                  ),
                                SizedBox(height: 3.h),
                                // Widget de preview dos mapas meteorológicos
                                const WeatherMapsPreviewWidget(),
                                SizedBox(height: 3.h),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to convert WeatherData to Map for compatibility with existing widgets
  Map<String, dynamic> _convertWeatherDataToMap(WeatherData weather) {
    return {
      "temperature": weather.temperature.round(),
      "realFeel": weather.feelsLike.round(),
      "condition": weather.description,
      "icon": weather.icon,
      "location": weather.location,
      "isCurrentLocation": true,
      "humidity": weather.humidity,
      "windSpeed": weather.windSpeed.round(),
      "windDirection": _getWindDirection(weather.windDirection),
      "pressure": weather.pressure.round(),
      "visibility": weather.visibility.round(),
      "uvIndex": weather.uvIndex,
      "sunrise":
          "${weather.sunrise.hour.toString().padLeft(2, '0')}:${weather.sunrise.minute.toString().padLeft(2, '0')}",
      "sunset":
          "${weather.sunset.hour.toString().padLeft(2, '0')}:${weather.sunset.minute.toString().padLeft(2, '0')}",
      "lastUpdated": "Agora"
    };
  }

  String _getDayOfWeek() {
    final days = [
      "Domingo",
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado"
    ];
    return days[DateTime.now().weekday % 7];
  }

  String _getWindDirection(int degrees) {
    if (degrees >= 315 || degrees < 45) return "N";
    if (degrees >= 45 && degrees < 135) return "E";
    if (degrees >= 135 && degrees < 225) return "S";
    return "W";
  }
}
