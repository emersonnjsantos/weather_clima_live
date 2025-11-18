import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';
import 'summary_chart.dart';
import 'rain_chart.dart';
import 'temperature_chart.dart';
import 'wind_chart.dart';

class HourlyChartsCarousel extends StatefulWidget {
  final List<HourlyWeather> hourlyForecast;
  final WeatherApiService weatherService;

  const HourlyChartsCarousel({
    Key? key,
    required this.hourlyForecast,
    required this.weatherService,
  }) : super(key: key);

  @override
  State<HourlyChartsCarousel> createState() => _HourlyChartsCarouselState();
}

class _HourlyChartsCarouselState extends State<HourlyChartsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _titles = [
    'Resumo',
    'Chuva',
    'Temperatura',
    'Vento',
  ];

  final List<IconData> _icons = [
    Icons.summarize,
    Icons.water_drop,
    Icons.thermostat,
    Icons.air,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicador de páginas
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.blue[50]
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[index],
                        size: 20.sp,
                        color: _currentPage == index
                            ? Colors.blue[700]
                            : Colors.grey[600],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _titles[index],
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: _currentPage == index
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _currentPage == index
                              ? Colors.blue[700]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Carrossel de gráficos
        SizedBox(
          height: 58.h,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              SummaryChart(
                hourlyForecast: widget.hourlyForecast,
                weatherService: widget.weatherService,
              ),
              RainChart(
                hourlyForecast: widget.hourlyForecast,
                weatherService: widget.weatherService,
              ),
              TemperatureChart(
                hourlyForecast: widget.hourlyForecast,
                weatherService: widget.weatherService,
              ),
              WindChart(
                hourlyForecast: widget.hourlyForecast,
                weatherService: widget.weatherService,
              ),
            ],
          ),
        ),

        // Indicador de pontos
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: _currentPage == index ? 8.w : 2.w,
              height: 1.h,
              decoration: BoxDecoration(
                color:
                    _currentPage == index ? Colors.blue[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
