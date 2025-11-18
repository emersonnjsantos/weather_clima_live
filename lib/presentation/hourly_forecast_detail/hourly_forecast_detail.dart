import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/hourly_weather_card_widget.dart';
import './widgets/precipitation_graph_widget.dart';
import './widgets/weather_alert_widget.dart';

class HourlyForecastDetail extends StatefulWidget {
  const HourlyForecastDetail({super.key});

  @override
  State<HourlyForecastDetail> createState() => _HourlyForecastDetailState();
}

class _HourlyForecastDetailState extends State<HourlyForecastDetail>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  int selectedHourIndex = -1;
  bool isLoading = false;
  String selectedView = 'precipitation';

  // Dados simulados de previsão horária
  final List<Map<String, dynamic>> hourlyForecast = [
    {
      "time": "14:00",
      "temperature": 28,
      "feelsLike": 32,
      "weatherIcon": "sunny",
      "condition": "Ensolarado",
      "precipitation": 0,
      "windSpeed": 12,
      "humidity": 45,
      "pressure": 1013,
      "visibility": 10,
      "uvIndex": 8,
    },
    {
      "time": "15:00",
      "temperature": 29,
      "feelsLike": 33,
      "weatherIcon": "sunny",
      "condition": "Ensolarado",
      "precipitation": 5,
      "windSpeed": 15,
      "humidity": 48,
      "pressure": 1012,
      "visibility": 10,
      "uvIndex": 9,
    },
    {
      "time": "16:00",
      "temperature": 27,
      "feelsLike": 30,
      "weatherIcon": "partly_cloudy",
      "condition": "Parcialmente Nublado",
      "precipitation": 15,
      "windSpeed": 18,
      "humidity": 52,
      "pressure": 1011,
      "visibility": 9,
      "uvIndex": 7,
    },
    {
      "time": "17:00",
      "temperature": 25,
      "feelsLike": 28,
      "weatherIcon": "cloudy",
      "condition": "Nublado",
      "precipitation": 25,
      "windSpeed": 20,
      "humidity": 58,
      "pressure": 1010,
      "visibility": 8,
      "uvIndex": 5,
    },
    {
      "time": "18:00",
      "temperature": 23,
      "feelsLike": 26,
      "weatherIcon": "rainy",
      "condition": "Chuva Leve",
      "precipitation": 65,
      "windSpeed": 22,
      "humidity": 72,
      "pressure": 1009,
      "visibility": 6,
      "uvIndex": 3,
    },
    {
      "time": "19:00",
      "temperature": 22,
      "feelsLike": 24,
      "weatherIcon": "rainy",
      "condition": "Chuva Moderada",
      "precipitation": 85,
      "windSpeed": 25,
      "humidity": 78,
      "pressure": 1008,
      "visibility": 5,
      "uvIndex": 2,
    },
    {
      "time": "20:00",
      "temperature": 21,
      "feelsLike": 23,
      "weatherIcon": "thunderstorm",
      "condition": "Tempestade",
      "precipitation": 95,
      "windSpeed": 30,
      "humidity": 85,
      "pressure": 1007,
      "visibility": 3,
      "uvIndex": 1,
    },
    {
      "time": "21:00",
      "temperature": 20,
      "feelsLike": 22,
      "weatherIcon": "rainy",
      "condition": "Chuva Forte",
      "precipitation": 90,
      "windSpeed": 28,
      "humidity": 82,
      "pressure": 1008,
      "visibility": 4,
      "uvIndex": 0,
    },
    {
      "time": "22:00",
      "temperature": 19,
      "feelsLike": 21,
      "weatherIcon": "cloudy",
      "condition": "Nublado",
      "precipitation": 40,
      "windSpeed": 20,
      "humidity": 75,
      "pressure": 1009,
      "visibility": 7,
      "uvIndex": 0,
    },
    {
      "time": "23:00",
      "temperature": 18,
      "feelsLike": 20,
      "weatherIcon": "partly_cloudy",
      "condition": "Parcialmente Nublado",
      "precipitation": 20,
      "windSpeed": 15,
      "humidity": 68,
      "pressure": 1010,
      "visibility": 8,
      "uvIndex": 0,
    },
    {
      "time": "00:00",
      "temperature": 17,
      "feelsLike": 19,
      "weatherIcon": "clear_night",
      "condition": "Céu Limpo",
      "precipitation": 5,
      "windSpeed": 12,
      "humidity": 62,
      "pressure": 1011,
      "visibility": 9,
      "uvIndex": 0,
    },
    {
      "time": "01:00",
      "temperature": 16,
      "feelsLike": 18,
      "weatherIcon": "clear_night",
      "condition": "Céu Limpo",
      "precipitation": 0,
      "windSpeed": 10,
      "humidity": 58,
      "pressure": 1012,
      "visibility": 10,
      "uvIndex": 0,
    },
  ];

  final List<Map<String, dynamic>> weatherAlerts = [
    {
      "type": "warning",
      "title": "Alerta de Tempestade",
      "description":
          "Possibilidade de tempestades entre 18:00 e 22:00. Ventos fortes e chuva intensa esperados.",
      "severity": "moderate",
      "startTime": "18:00",
      "endTime": "22:00",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });

    // Simular chamada de API
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  void _onHourSelected(int index) {
    setState(() {
      selectedHourIndex = selectedHourIndex == index ? -1 : index;
    });

    if (selectedHourIndex != -1) {
      _scrollToHour(index);
    }
  }

  void _scrollToHour(int index) {
    final double itemHeight = 12.h;
    final double targetOffset = index * itemHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _shareWeatherData() {
    // Simular funcionalidade de compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Previsão horária compartilhada!',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'São Paulo',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _shareWeatherData,
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: Column(
            children: [
              // Cabeçalho fixo
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Próximas 24 Horas',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de abas para visualizações de dados
              Container(
                color: AppTheme.lightTheme.colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.lightTheme.colorScheme.primary,
                  unselectedLabelColor:
                      AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  indicatorColor: AppTheme.lightTheme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Precipitação'),
                    Tab(text: 'Temperatura'),
                    Tab(text: 'Vento'),
                  ],
                  onTap: (index) {
                    setState(() {
                      selectedView =
                          ['precipitation', 'temperature', 'wind'][index];
                    });
                  },
                ),
              ),

              // Conteúdo principal
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPrecipitationView(),
                    _buildTemperatureView(),
                    _buildWindView(),
                  ],
                ),
              ),

              // Seção de alertas meteorológicos
              if (weatherAlerts.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(4.w),
                  child: WeatherAlertWidget(
                    alerts: weatherAlerts,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrecipitationView() {
    return Column(
      children: [
        // Gráfico de precipitação
        Container(
          height: 25.h,
          margin: EdgeInsets.all(4.w),
          child: PrecipitationGraphWidget(
            hourlyData: hourlyForecast,
            onHourSelected: _onHourSelected,
            selectedIndex: selectedHourIndex,
          ),
        ),

        // Linha do tempo horária
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final hourData = hourlyForecast[index];
              return HourlyWeatherCardWidget(
                hourData: hourData,
                isExpanded: selectedHourIndex == index,
                isLoading: isLoading,
                onTap: () => _onHourSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureView() {
    return Column(
      children: [
        // Gráfico de temperatura
        Container(
          height: 25.h,
          margin: EdgeInsets.all(4.w),
          child: _buildTemperatureGraph(),
        ),

        // Linha do tempo horária
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final hourData = hourlyForecast[index];
              return HourlyWeatherCardWidget(
                hourData: hourData,
                isExpanded: selectedHourIndex == index,
                isLoading: isLoading,
                onTap: () => _onHourSelected(index),
                highlightTemperature: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWindView() {
    return Column(
      children: [
        // Gráfico de vento
        Container(
          height: 25.h,
          margin: EdgeInsets.all(4.w),
          child: _buildWindGraph(),
        ),

        // Linha do tempo horária
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final hourData = hourlyForecast[index];
              return HourlyWeatherCardWidget(
                hourData: hourData,
                isExpanded: selectedHourIndex == index,
                isLoading: isLoading,
                onTap: () => _onHourSelected(index),
                highlightWind: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureGraph() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperatura (°C)',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}°',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < hourlyForecast.length) {
                            return Text(
                              hourlyForecast[value.toInt()]["time"] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: hourlyForecast.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value["temperature"] as int).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindGraph() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Velocidade do Vento (km/h)',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < hourlyForecast.length) {
                            return Text(
                              hourlyForecast[value.toInt()]["time"] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: hourlyForecast.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value["windSpeed"] as int).toDouble(),
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
