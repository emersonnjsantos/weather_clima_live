import 'package:flutter/material.dart';

import '../presentation/city_search/city_search.dart';
import '../presentation/daily_detail/daily_detail_screen.dart';
import '../presentation/favorite_cities/favorite_cities.dart';
import '../presentation/hourly_chart/hourly_chart_screen.dart';
import '../presentation/hourly_forecast_detail/hourly_forecast_detail.dart';
import '../presentation/icon_manager/icon_manager_screen.dart';
import '../presentation/location_permission_onboarding/location_permission_onboarding.dart';
import '../presentation/news_screen/news_screen.dart';
import '../presentation/notifications/notifications_center_screen.dart';
import '../presentation/premium/premium_screen.dart';
import '../presentation/scope/scope_screen.dart';
import '../presentation/settings/advanced_customization_screen.dart';
import '../presentation/settings/information_screen.dart';
import '../presentation/settings/measurement_units_screen.dart';
import '../presentation/settings/profile_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/weather_dashboard/weather_dashboard.dart';
import '../presentation/weather_maps/weather_maps_screen_webview.dart';

class AppRoutes {
  // TODO: Adicione suas rotas aqui
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String locationPermissionOnboarding =
      '/location-permission-onboarding';
  static const String citySearch = '/city-search';
  static const String favoriteCities = '/favorite-cities';
  static const String weatherDashboard = '/weather-dashboard';
  static const String hourlyForecastDetail = '/hourly-forecast-detail';
  static const String dailyDetail = '/daily-detail';
  static const String settings = '/settings';
  static const String newsScreen = '/news-screen';
  static const String iconManager = '/icon-manager';
  static const String hourlyChart = '/hourly-chart';
  static const String weatherMaps = '/weather-maps';
  static const String advancedCustomization = '/advanced_customization';
  static const String notificationsCenter = '/notifications-center';
  static const String scope = '/scope';
  static const String measurementUnits = '/measurement-units';
  static const String profile = '/profile';
  static const String information = '/information';
  static const String premium = '/premium';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LocationPermissionOnboarding(),
    splashScreen: (context) => const SplashScreen(),
    locationPermissionOnboarding: (context) =>
        const LocationPermissionOnboarding(),
    citySearch: (context) => const CitySearch(),
    favoriteCities: (context) => const FavoriteCities(),
    weatherDashboard: (context) => const WeatherDashboard(),
    hourlyForecastDetail: (context) => const HourlyForecastDetail(),
    dailyDetail: (context) => const DailyDetailScreen(),
    settings: (context) => const SettingsScreen(),
    newsScreen: (context) => const NewsScreen(),
    iconManager: (context) => const IconManagerScreen(),
    hourlyChart: (context) => const HourlyChartScreen(),
    weatherMaps: (context) => const WeatherMapsScreenWebView(),
    advancedCustomization: (context) => const AdvancedCustomizationScreen(),
    notificationsCenter: (context) => const NotificationsCenterScreen(),
    scope: (context) => const ScopeScreen(),
    measurementUnits: (context) => const MeasurementUnitsScreen(),
    profile: (context) => const ProfileScreen(),
    information: (context) => const InformationScreen(),
    premium: (context) => const PremiumScreen(),
    // TODO: Adicione suas outras rotas aqui
  };
}
