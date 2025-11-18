import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherAlertWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const WeatherAlertWidget({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas Meteorológicos',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final alertType = alert["type"] as String;
    final severity = alert["severity"] as String;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getAlertBackgroundColor(severity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAlertBorderColor(severity),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getAlertIconColor(severity),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getAlertIconName(alertType),
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert["title"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${alert["startTime"]} - ${alert["endTime"]}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getSeverityColor(severity),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getSeverityLabel(severity),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            alert["description"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Manipular visualização de detalhes
                  },
                  icon: CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  label: Text(
                    'Ver Detalhes',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Manipular dispensar alerta
                  },
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 16,
                  ),
                  label: Text(
                    'Dispensar',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAlertIconName(String alertType) {
    switch (alertType) {
      case 'warning':
        return 'warning';
      case 'watch':
        return 'visibility';
      case 'advisory':
        return 'info';
      default:
        return 'warning';
    }
  }

  Color _getAlertIconColor(String severity) {
    switch (severity) {
      case 'severe':
        return AppTheme.lightTheme.colorScheme.error;
      case 'moderate':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'minor':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  Color _getAlertBackgroundColor(String severity) {
    switch (severity) {
      case 'severe':
        return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1);
      case 'moderate':
        return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1);
      case 'minor':
        return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1);
      default:
        return AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1);
    }
  }

  Color _getAlertBorderColor(String severity) {
    switch (severity) {
      case 'severe':
        return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3);
      case 'moderate':
        return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3);
      case 'minor':
        return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3);
      default:
        return AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3);
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'severe':
        return AppTheme.lightTheme.colorScheme.error;
      case 'moderate':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'minor':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity) {
      case 'severe':
        return 'SEVERO';
      case 'moderate':
        return 'MODERADO';
      case 'minor':
        return 'MENOR';
      default:
        return 'INFORMATIVO';
    }
  }
}
