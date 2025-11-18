import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HourlyWeatherCardWidget extends StatelessWidget {
  final Map<String, dynamic> hourData;
  final bool isExpanded;
  final bool isLoading;
  final VoidCallback onTap;
  final bool highlightTemperature;
  final bool highlightWind;

  const HourlyWeatherCardWidget({
    super.key,
    required this.hourData,
    required this.isExpanded,
    required this.isLoading,
    required this.onTap,
    this.highlightTemperature = false,
    this.highlightWind = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 2.h),
      child: Card(
        elevation: isExpanded ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isExpanded
              ? BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                _buildMainContent(),
                if (isExpanded) ...[
                  SizedBox(height: 2.h),
                  _buildExpandedContent(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Row(
      children: [
        // Hora
        SizedBox(
          width: 15.w,
          child: Text(
            hourData["time"] as String,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(width: 4.w),

        // Ícone do clima
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: _getWeatherIconColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: _getWeatherIconName(),
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),

        SizedBox(width: 4.w),

        // Temperatura
        Expanded(
          flex: 2,
          child: Container(
            padding: highlightTemperature
                ? EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h)
                : null,
            decoration: highlightTemperature
                ? BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              '${hourData["temperature"]}°C',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: highlightTemperature
                    ? AppTheme.lightTheme.colorScheme.onPrimaryContainer
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // Precipitação
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'water_drop',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${hourData["precipitation"]}%',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Velocidade do vento
        Expanded(
          child: Container(
            padding: highlightWind
                ? EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h)
                : null,
            decoration: highlightWind
                ? BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'air',
                  color: highlightWind
                      ? AppTheme.lightTheme.colorScheme.onSecondaryContainer
                      : AppTheme.lightTheme.colorScheme.secondary,
                  size: 16,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${hourData["windSpeed"]}km/h',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: highlightWind
                        ? AppTheme.lightTheme.colorScheme.onSecondaryContainer
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Umidade
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'opacity',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 16,
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${hourData["humidity"]}%',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Ícone expandir/recolher
        CustomIconWidget(
          iconName: isExpanded ? 'expand_less' : 'expand_more',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descrição da condição climática
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _getWeatherIconColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hourData["condition"] as String,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 2.h),

          // Grade de métricas detalhadas
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 1.h,
            children: [
              _buildMetricItem(
                'Sensação Térmica',
                '${hourData["feelsLike"]}°C',
                'thermostat',
              ),
              _buildMetricItem(
                'Pressão',
                '${hourData["pressure"]} hPa',
                'speed',
              ),
              _buildMetricItem(
                'Visibilidade',
                '${hourData["visibility"]} km',
                'visibility',
              ),
              _buildMetricItem(
                'Índice UV',
                '${hourData["uvIndex"]}',
                'wb_sunny',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String iconName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeatherIconName() {
    switch (hourData["weatherIcon"] as String) {
      case 'sunny':
        return 'wb_sunny';
      case 'partly_cloudy':
        return 'partly_cloudy_day';
      case 'cloudy':
        return 'cloud';
      case 'rainy':
        return 'rainy';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'clear_night':
        return 'nights_stay';
      default:
        return 'wb_sunny';
    }
  }

  Color _getWeatherIconColor() {
    switch (hourData["weatherIcon"] as String) {
      case 'sunny':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'partly_cloudy':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'cloudy':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'rainy':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'thunderstorm':
        return AppTheme.weatherStormLight;
      case 'clear_night':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
