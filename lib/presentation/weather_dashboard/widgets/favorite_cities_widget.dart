import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FavoriteCitiesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cities;
  final Function(Map<String, dynamic>)? onCityTap;
  final Function(Map<String, dynamic>)? onCityLongPress;

  const FavoriteCitiesWidget({
    super.key,
    required this.cities,
    this.onCityTap,
    this.onCityLongPress,
  });

  String _getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') ||
        conditionLower.contains('sunny') ||
        conditionLower.contains('ensolarado')) {
      return 'wb_sunny';
    } else if (conditionLower.contains('cloud') ||
        conditionLower.contains('nublado')) {
      return 'cloud';
    } else if (conditionLower.contains('rain') ||
        conditionLower.contains('chuva')) {
      return 'grain';
    } else if (conditionLower.contains('storm')) {
      return 'thunderstorm';
    }
    return 'wb_sunny';
  }

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cidades Favoritas',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          // Horizontal Scrollable Cities
          SizedBox(
            height: 15.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final name = city["name"] as String? ?? "";
                final temperature = city["temperature"] as int? ?? 0;
                final condition = city["condition"] as String? ?? "";
                final icon = city["icon"] as String? ?? "";

                return GestureDetector(
                  onTap: () => onCityTap?.call(city),
                  onLongPress: () => onCityLongPress?.call(city),
                  child: Container(
                    width: 35.w,
                    margin: EdgeInsets.only(right: 3.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.dividerLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // City Name
                        Text(
                          name,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: AppTheme.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                        // Weather Icon and Temperature
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomIconWidget(
                              iconName: _getWeatherIcon(icon),
                              color: AppTheme.accentLight,
                              size: 32,
                            ),
                            Text(
                              '$temperature°',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: AppTheme.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Condition
                        Text(
                          condition,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
