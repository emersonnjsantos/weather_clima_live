import 'package:flutter/material.dart';

/// Widget de ícones customizado que mapeia nomes de string para [IconData].
///
/// Contém apenas os ícones efetivamente usados no app, reduzindo
/// o tamanho do widget de ~2200 linhas para ~100.
class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const CustomIconWidget(
      {super.key, required this.iconName, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      _resolveIcon(iconName),
      size: size,
      color: color,
    );
  }

  /// Mapa de ícones usados no app — apenas os necessários.
  static final Map<String, IconData> _iconMap = {
    // Weather
    'wb_sunny': Icons.wb_sunny,
    'wb_twilight': Icons.wb_twilight,
    'wb_cloudy': Icons.wb_cloudy,
    'cloud': Icons.cloud,
    'grain': Icons.grain,
    'thunderstorm': Icons.thunderstorm,
    'ac_unit': Icons.ac_unit,
    'water_drop': Icons.water_drop,
    'air': Icons.air,
    'opacity': Icons.opacity,
    'nightlight_round': Icons.nightlight_round,
    'nights_stay': Icons.nights_stay,
    'light_mode': Icons.light_mode,
    'brightness_3': Icons.brightness_3,

    // Navigation
    'arrow_back': Icons.arrow_back,
    'close': Icons.close,
    'clear': Icons.clear,
    'search': Icons.search,
    'search_off': Icons.search_off,

    // Actions
    'add': Icons.add,
    'delete': Icons.delete,
    'share': Icons.share,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,

    // Info
    'info': Icons.info,
    'info_outline': Icons.info_outline,
    'visibility': Icons.visibility,
    'schedule': Icons.schedule,
    'access_time': Icons.access_time,
    'history': Icons.history,
    'lightbulb': Icons.lightbulb,
    'security': Icons.security,
    'zoom_in': Icons.zoom_in,

    // Location
    'location_on': Icons.location_on,
    'my_location': Icons.my_location,
    'place': Icons.place,
    'explore': Icons.explore,
    'near_me': Icons.near_me,

    // UI elements
    'settings': Icons.settings,
    'menu': Icons.menu,
    'more_vert': Icons.more_vert,
    'refresh': Icons.refresh,
    'notifications': Icons.notifications,
    'dark_mode': Icons.dark_mode,
    'error': Icons.error,
    'warning': Icons.warning,
    'check_circle': Icons.check_circle,
  };

  /// Resolve o nome para o [IconData] correspondente.
  /// Retorna [Icons.help_outline] como fallback para ícones desconhecidos.
  static IconData _resolveIcon(String name) {
    return _iconMap[name] ?? Icons.help_outline;
  }
}
