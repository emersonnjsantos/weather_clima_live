import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherMetricsWidget({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final humidity = weatherData["humidity"] as int? ?? 0;
    final windSpeed = weatherData["windSpeed"] as int? ?? 0;
    final windDirection = weatherData["windDirection"] as String? ?? "";
    final pressure = weatherData["pressure"] as int? ?? 0;
    final visibility = weatherData["visibility"] as int? ?? 0;
    final uvIndex = weatherData["uvIndex"] as int? ?? 0;
    final sunrise = weatherData["sunrise"] as String? ?? "";
    final sunset = weatherData["sunset"] as String? ?? "";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes do Tempo',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          // Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            children: [
              _buildMetricCard(
                icon: 'water_drop',
                title: 'Umidade',
                value: '$humidity%',
                subtitle: humidity > 70
                    ? 'Alta'
                    : humidity > 40
                        ? 'Moderada'
                        : 'Baixa',
              ),
              _buildMetricCard(
                icon: 'air',
                title: 'Vento',
                value: '$windSpeed km/h',
                subtitle: windDirection,
              ),
              _buildMetricCard(
                icon: 'compress',
                title: 'Pressão',
                value: '$pressure hPa',
                subtitle: pressure > 1020
                    ? 'Alta'
                    : pressure > 1000
                        ? 'Normal'
                        : 'Baixa',
              ),
              _buildMetricCard(
                icon: 'visibility',
                title: 'Visibilidade',
                value: '$visibility km',
                subtitle: visibility > 8
                    ? 'Excelente'
                    : visibility > 5
                        ? 'Boa'
                        : 'Limitada',
              ),
              _buildMetricCard(
                icon: 'wb_sunny',
                title: 'Índice UV',
                value: uvIndex.toString(),
                subtitle: _getUVDescription(uvIndex),
              ),
              _buildSunriseSunsetCard(sunrise, sunset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunsetCard(String sunrise, String sunset) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'wb_twilight',
                color: AppTheme.accentLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sol',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sunrise,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Nascer',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sunset,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Pôr',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUVDescription(int uvIndex) {
    if (uvIndex <= 2) return 'Baixo';
    if (uvIndex <= 5) return 'Moderado';
    if (uvIndex <= 7) return 'Alto';
    if (uvIndex <= 10) return 'Muito Alto';
    return 'Extremo';
  }
}
