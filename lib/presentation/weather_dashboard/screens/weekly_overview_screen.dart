import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/weather_models.dart';
import '../../../widgets/custom_image_widget.dart';

class WeeklyOverviewScreen extends StatefulWidget {
  final WeatherData weatherData;

  const WeeklyOverviewScreen({
    super.key,
    required this.weatherData,
  });

  @override
  State<WeeklyOverviewScreen> createState() => _WeeklyOverviewScreenState();
}

class _WeeklyOverviewScreenState extends State<WeeklyOverviewScreen> {
  late final List<_WeeklyTabData> _tabs;
  int _selectedIndex = 0;
  bool _isDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
  }

  List<_WeeklyTabData> _buildTabs() {
    final daily = widget.weatherData.dailyForecast;
    if (daily.isEmpty) {
      return List.generate(7, (index) {
        final date = widget.weatherData.lastUpdated.add(Duration(days: index));
        return _WeeklyTabData(
          date: date,
          displayLabel: _labelForIndex(index, date),
        );
      });
    }

    return List.generate(daily.length, (index) {
      final day = daily[index];
      return _WeeklyTabData(
        date: day.date,
        displayLabel: _labelForIndex(index, day.date),
        weather: day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _tabs[_selectedIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.blueGrey[700],
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.weatherData.location,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
            Text(
              'Atualizado ${_formatTime(widget.weatherData.lastUpdated)}',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.h),
          _buildCarousel(),
          SizedBox(height: 1.5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _ExpandableForecastCard(
              tab: selected,
              fallBack: widget.weatherData,
              isExpanded: _isDetailsExpanded,
              onToggle: () {
                setState(() {
                  _isDetailsExpanded = !_isDetailsExpanded;
                });
              },
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: _DayDetailCard(tab: selected, fallBack: widget.weatherData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 8.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  tab.displayLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blue : Colors.grey[500],
                  ),
                ),
                SizedBox(height: 0.8.h),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 0.5.h,
                  width: 10.w,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 5.w),
        itemCount: _tabs.length,
      ),
    );
  }

  String _labelForIndex(int index, DateTime date) {
    if (index == 0) return 'HOJE';
    if (index == 1) return 'AMANHÃ';
    final weekday = _weekdayAbbrev(date.weekday);
    final day = date.day.toString().padLeft(2, '0');
    return '$weekday. $day';
  }

  String _weekdayAbbrev(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'SEG';
      case DateTime.tuesday:
        return 'TER';
      case DateTime.wednesday:
        return 'QUA';
      case DateTime.thursday:
        return 'QUI';
      case DateTime.friday:
        return 'SEX';
      case DateTime.saturday:
        return 'SÁB';
      default:
        return 'DOM';
    }
  }

  String _formatTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class _DayDetailCard extends StatelessWidget {
  final _WeeklyTabData tab;
  final WeatherData fallBack;

  const _DayDetailCard({
    required this.tab,
    required this.fallBack,
  });

  @override
  Widget build(BuildContext context) {
    final weather = tab.weather;
    final description =
        weather?.description ?? fallBack.description.toUpperCase();
    final high = weather?.high ?? fallBack.temperature;
    final low = weather?.low ?? fallBack.temperature;
    final precipitation = weather?.precipitation ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fullDate(tab.date),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blueGrey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TemperatureColumn(
                label: 'MÁX',
                value: '${high.round()}°',
              ),
              _TemperatureColumn(
                label: 'MÍN',
                value: '${low.round()}°',
              ),
              _TemperatureColumn(
                label: 'CHUVA',
                value: '$precipitation%',
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Divider(color: Colors.white.withValues(alpha: 0.6)),
          SizedBox(height: 2.h),
          Text(
            'Resumo do dia',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _buildSummary(weather),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blueGrey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummary(DailyWeather? weather) {
    if (weather == null) {
      return 'Acompanhe o detalhamento completo da previsão para este local.';
    }

    final condition = weather.description;
    final high = weather.high.round();
    final low = weather.low.round();
    return 'Dia com $condition. Temperaturas entre $low° e $high°. Probabilidade de chuva em ${weather.precipitation}% do período.';
  }

  String _fullDate(DateTime date) {
    final week = _weekdayName(date.weekday);
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthName(date.month);
    return '$week, $day de $month';
  }
}

class _ExpandableForecastCard extends StatelessWidget {
  final _WeeklyTabData tab;
  final WeatherData fallBack;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableForecastCard({
    required this.tab,
    required this.fallBack,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final weather = tab.weather;
    final description =
        weather?.description ?? fallBack.description.toLowerCase();
    final capitalized =
        description.isNotEmpty ? _capitalizeSentence(description) : '';
    final iconCode = weather?.icon ?? fallBack.icon;
    final iconUrl = _iconUrl(iconCode);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(2.5.w),
                child: CustomImageWidget(
                  imageUrl: iconUrl,
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                  errorWidget: Icon(
                    Icons.cloud_queue,
                    size: 32,
                    color: Colors.blue[600],
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headlineDate(tab.date),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      capitalized,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      'Pela manhã',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.blueGrey[400],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 26,
                    color: Colors.blueGrey[500],
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                _detailedNarrative(tab, fallBack),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blueGrey[700],
                  height: 1.4,
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  String _headlineDate(DateTime date) {
    final weekday = _weekdayName(date.weekday);
    final month = _monthName(date.month);
    return '$weekday $month ${date.day}';
  }

  String? _iconUrl(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) return null;
    return 'https://openweathermap.org/img/wn/${iconCode}@2x.png';
  }

  static String _capitalizeSentence(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _detailedNarrative(_WeeklyTabData tab, WeatherData fallback) {
    final day = tab.weather;
    final description = day?.description ?? fallback.description;
    final double high = day?.high ?? fallback.temperature;
    final double low = day?.low ?? fallback.temperature;
    final precip = day?.precipitation ?? 0;
    final wind = fallback.windSpeed.round();

    return 'Hoje, ${description.toLowerCase()} ao longo do dia, '
        'com temperaturas entre ${low.round()}°C e ${high.round()}°C. '
        'A chance de chuva é de $precip%. Ventos médios de ${wind} km/h.';
  }
}

class _TemperatureColumn extends StatelessWidget {
  final String label;
  final String value;

  const _TemperatureColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey[500],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
          ),
        ),
      ],
    );
  }
}

class _WeeklyTabData {
  final DateTime date;
  final String displayLabel;
  final DailyWeather? weather;

  _WeeklyTabData({
    required this.date,
    required this.displayLabel,
    this.weather,
  });
}

String _weekdayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Segunda-feira';
    case DateTime.tuesday:
      return 'Terça-feira';
    case DateTime.wednesday:
      return 'Quarta-feira';
    case DateTime.thursday:
      return 'Quinta-feira';
    case DateTime.friday:
      return 'Sexta-feira';
    case DateTime.saturday:
      return 'Sábado';
    default:
      return 'Domingo';
  }
}

String _monthName(int month) {
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  return months[(month - 1).clamp(0, 11)];
}

