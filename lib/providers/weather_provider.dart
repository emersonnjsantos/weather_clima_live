import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatherpro/di/service_locator.dart';
import 'package:weatherpro/models/weather_models.dart';
import 'package:weatherpro/repositories/weather_repository.dart';

/// Estado do provider de clima.
class WeatherState {
  final bool isLoading;
  final WeatherData? data;
  final String? error;

  const WeatherState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  WeatherState copyWith({
    bool? isLoading,
    WeatherData? data,
    String? error,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

/// Notifier que gerencia o estado do clima via Riverpod.
class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;

  WeatherNotifier(this._repository) : super(const WeatherState());

  /// Busca dados de clima por coordenadas.
  Future<void> fetchWeather(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.getWeatherData(lat, lon);
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Busca clima da localização atual.
  Future<void> fetchCurrentLocationWeather() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.getWeatherForCurrentLocation();
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider global de clima usando Riverpod.
final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(getIt<WeatherRepository>());
});
