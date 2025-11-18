import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final VoidCallback? onLocationTap;

  const CurrentWeatherWidget({
    super.key,
    required this.weatherData,
    this.onLocationTap,
  });

  String _getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sunny')) {
      return 'wb_sunny';
    } else if (conditionLower.contains('cloud')) {
      return 'cloud';
    } else if (conditionLower.contains('rain')) {
      return 'grain';
    } else if (conditionLower.contains('storm')) {
      return 'thunderstorm';
    }
    return 'wb_sunny';
  }

  @override
  Widget build(BuildContext context) {
    final temperature = weatherData["temperature"] as int? ?? 0;
    final realFeel = weatherData["realFeel"] as int? ?? 0;
    final condition = weatherData["condition"] as String? ?? "";
    final windSpeed = (weatherData["windSpeed"] as num?)?.toDouble() ?? 0.0;
    final windDirection = weatherData["windDirection"] as String? ?? "";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00BCD4), // Cyan
            Color(0xFF0097A7), // Cyan darker
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Condition at top
          Text(
            condition,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 2.h),

          // Weather Icon and Temperature
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Weather Icon
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomIconWidget(
                  iconName: _getWeatherIcon(condition),
                  color: Colors.white,
                  size: 50,
                ),
              ),

              SizedBox(width: 4.w),

              // Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$temperature°',
                    style: TextStyle(
                      fontSize: 64.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'Sensação de $realFeel°',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Wind info (right side)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wind direction arrow
                  Icon(
                    Icons.north_east,
                    color: Colors.black87,
                    size: 26,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    windDirection,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${windSpeed.toInt()} km/h',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
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
}
