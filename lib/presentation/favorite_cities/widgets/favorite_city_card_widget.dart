import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FavoriteCityCardWidget extends StatelessWidget {
  final Map<String, dynamic> cityData;
  final bool isEditMode;
  final bool isSelected;
  final bool isRefreshing;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(String) onDelete;
  final Function(String) onSetDefault;
  final Function(Map<String, dynamic>) onShare;

  const FavoriteCityCardWidget({
    super.key,
    required this.cityData,
    required this.isEditMode,
    required this.isSelected,
    required this.isRefreshing,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    required this.onSetDefault,
    required this.onShare,
  });

  String _getWeatherIconName(String weatherIcon) {
    switch (weatherIcon) {
      case 'sunny':
        return 'wb_sunny';
      case 'partly_cloudy_day':
        return 'wb_cloudy';
      case 'cloud':
        return 'cloud';
      case 'light_rain':
        return 'grain';
      case 'storm':
        return 'thunderstorm';
      default:
        return 'wb_sunny';
    }
  }

  Color _getWeatherColor(String weatherIcon) {
    switch (weatherIcon) {
      case 'sunny':
        return AppTheme.accentLight;
      case 'partly_cloudy_day':
        return AppTheme.weatherCloudyLight;
      case 'cloud':
        return AppTheme.weatherCloudyLight;
      case 'light_rain':
        return AppTheme.lightTheme.primaryColor;
      case 'storm':
        return AppTheme.weatherStormLight;
      default:
        return AppTheme.accentLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(cityData["id"]),
      direction:
          isEditMode ? DismissDirection.none : DismissDirection.horizontal,
      background: _buildSwipeBackground(isLeft: true),
      secondaryBackground: _buildSwipeBackground(isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        } else if (direction == DismissDirection.startToEnd) {
          _showQuickActions(context);
          return false;
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.lightTheme.cardColor,
            borderRadius: BorderRadius.circular(16.0),
            border: isSelected
                ? Border.all(
                    color: AppTheme.lightTheme.primaryColor,
                    width: 2.0,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                if (isEditMode)
                  Container(
                    margin: EdgeInsets.only(right: 3.w),
                    child: CustomIconWidget(
                      iconName: isSelected
                          ? 'check_circle'
                          : 'radio_button_unchecked',
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.textSecondaryLight,
                      size: 24,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        cityData["cityName"] ?? "",
                                        style: AppTheme
                                            .lightTheme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (cityData["isDefault"] == true) ...[
                                      SizedBox(width: 1.w),
                                      CustomIconWidget(
                                        iconName: 'star',
                                        color: AppTheme.accentLight,
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  '${cityData["country"]} • ${cityData["localTime"]}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${cityData["temperature"]}°',
                                    style: AppTheme
                                        .lightTheme.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _getWeatherColor(
                                          cityData["weatherIcon"]),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  if (isRefreshing)
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppTheme.lightTheme.primaryColor,
                                        ),
                                      ),
                                    )
                                  else
                                    CustomIconWidget(
                                      iconName: _getWeatherIconName(
                                          cityData["weatherIcon"]),
                                      color: _getWeatherColor(
                                          cityData["weatherIcon"]),
                                      size: 32,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cityData["condition"] ?? "",
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Máx ${cityData["highTemp"]}° • Mín ${cityData["lowTemp"]}°',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      if (cityData["lastUpdated"] != null) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          'Atualizado ${cityData["lastUpdated"]}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.textSecondaryLight
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: isLeft ? AppTheme.lightTheme.primaryColor : AppTheme.errorLight,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'more_horiz' : 'delete',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'Ações' : 'Excluir',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Remover dos Favoritos',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              content: Text(
                'Tem certeza de que deseja remover ${cityData["cityName"]} dos seus favoritos?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.textSecondaryLight),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onDelete(cityData["id"]);
                  },
                  child: Text(
                    'Remover',
                    style: TextStyle(color: AppTheme.errorLight),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.bottomSheetTheme.backgroundColor,
      shape: AppTheme.lightTheme.bottomSheetTheme.shape,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 2.h, bottom: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.dividerLight,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'visibility',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                title: Text(
                  'Ver Detalhes',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              if (cityData["isDefault"] != true)
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.accentLight,
                    size: 24,
                  ),
                  title: Text(
                    'Definir como Padrão',
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSetDefault(cityData["id"]);
                  },
                ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                title: Text(
                  'Compartilhar Tempo',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onShare(cityData);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.errorLight,
                  size: 24,
                ),
                title: Text(
                  'Remover dos Favoritos',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.errorLight,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final shouldDelete = await _showDeleteConfirmation(context);
                  if (shouldDelete) {
                    onDelete(cityData["id"]);
                  }
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}
