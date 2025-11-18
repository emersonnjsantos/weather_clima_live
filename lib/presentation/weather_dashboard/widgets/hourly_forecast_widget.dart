import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyWeather> hourlyForecast;
  final VoidCallback? onViewDetails;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyForecast,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Por horas',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
                ),
              ),
              if (onViewDetails != null)
                GestureDetector(
                  onTap: onViewDetails,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: const Color(0xFF1976D2),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Intervalos nublados nas próximas horas',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 15.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecast.length > 8 ? 8 : hourlyForecast.length,
              itemBuilder: (context, index) {
                final hourly = hourlyForecast[index];
                return _buildHourlyItem(hourly);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(HourlyWeather hourly) {
    final weatherService = WeatherApiService();

    return Container(
      margin: EdgeInsets.only(right: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hora
          Text(
            _formatHour(hourly.time),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 1.h),

          // Ícone do clima
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getIconColor(hourly.icon).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.network(
              weatherService.getWeatherIconUrl(hourly.icon, size: '4x'),
              width: 11.w,
              height: 11.w,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.wb_sunny,
                  size: 11.w,
                  color: _getIconColor(hourly.icon),
                );
              },
            ),
          ),

          SizedBox(height: 1.h),

          // Temperatura
          Text(
            '${hourly.temperature.round()}°',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Cores baseadas no tipo de clima para sombra
  Color _getIconColor(String iconCode) {
    if (iconCode.contains('01')) return Colors.orange; // Céu limpo
    if (iconCode.contains('02')) return Colors.amber; // Poucas nuvens
    if (iconCode.contains('03') || iconCode.contains('04')) {
      return Colors.grey; // Nublado
    }
    if (iconCode.contains('09') || iconCode.contains('10')) {
      return Colors.blue; // Chuva
    }
    if (iconCode.contains('11')) return Colors.purple; // Tempestade
    if (iconCode.contains('13')) return Colors.lightBlue; // Neve
    if (iconCode.contains('50')) return Colors.blueGrey; // Neblina
    return Colors.blue;
  }

  String _formatHour(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    return '$hour:00';
  }
}
