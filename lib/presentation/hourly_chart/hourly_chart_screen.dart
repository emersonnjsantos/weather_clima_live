import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../repositories/weather_repository.dart';
import '../../models/weather_models.dart';
import '../../services/weather_api_service.dart';
import 'widgets/summary_chart.dart';
import 'widgets/rain_chart.dart';
import 'widgets/temperature_chart.dart';
import 'widgets/wind_chart.dart';

/// Tela de gráficos detalhados por horas
/// Exibe 4 abas: Resumo, Chuva, Temperatura e Vento
/// Cada aba utiliza um widget separado para melhor organização do código
class HourlyChartScreen extends StatefulWidget {
  const HourlyChartScreen({Key? key}) : super(key: key);

  @override
  State<HourlyChartScreen> createState() => _HourlyChartScreenState();
}

class _HourlyChartScreenState extends State<HourlyChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WeatherRepository _weatherRepository = WeatherRepository();
  final WeatherApiService _weatherService = WeatherApiService();

  bool _isLoading = true;
  List<HourlyWeather> _hourlyForecast = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWeatherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherRepository.getCurrentWeather();
      setState(() {
        _hourlyForecast = weather.hourlyForecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Gráficos por Horas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadWeatherData,
              tooltip: 'Atualizar dados',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.summarize),
                text: 'Resumo',
              ),
              Tab(
                icon: Icon(Icons.water_drop),
                text: 'Chuva',
              ),
              Tab(
                icon: Icon(Icons.thermostat),
                text: 'Temperatura',
              ),
              Tab(
                icon: Icon(Icons.air),
                text: 'Vento',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 2.h),
                    Text(
                      'Carregando dados...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
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
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 3.h),
                        ElevatedButton.icon(
                          onPressed: _loadWeatherData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _hourlyForecast.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Nenhum dado disponível',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Resumo - Gráfico combinado de temperatura e precipitação
                          SingleChildScrollView(
                            child: SummaryChart(
                              hourlyForecast: _hourlyForecast,
                              weatherService: _weatherService,
                            ),
                          ),

                          // Tab 2: Chuva - Nebulosidade, Pressão e Precipitação
                          SingleChildScrollView(
                            child: RainChart(
                              hourlyForecast: _hourlyForecast,
                              weatherService: _weatherService,
                            ),
                          ),

                          // Tab 3: Temperatura - Temperatura real e sensação térmica
                          SingleChildScrollView(
                            child: TemperatureChart(
                              hourlyForecast: _hourlyForecast,
                              weatherService: _weatherService,
                            ),
                          ),

                          // Tab 4: Vento - Velocidade e rajadas de vento
                          SingleChildScrollView(
                            child: WindChart(
                              hourlyForecast: _hourlyForecast,
                              weatherService: _weatherService,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
