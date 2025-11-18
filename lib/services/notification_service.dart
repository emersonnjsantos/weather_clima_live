import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/weather_models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Trata o toque na notificação
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // Android 13+ requer permissão em tempo de execução
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    // Permissões do iOS
    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> showWeatherNotification(WeatherData weather) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'weather_updates',
      'Atualizações do Clima',
      channelDescription: 'Notificações com informações do clima atual',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      ongoing: true, // Notificação persistente
      autoCancel: false,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Formata a notificação
    final title = '${weather.location} • agora';
    final body = '${weather.condition}... ${weather.temperature.toInt()}°';

    await _notifications.show(
      0, // ID fixo para substituir a notificação anterior
      title,
      body,
      notificationDetails,
      payload: weather.location,
    );
  }

  Future<void> cancelWeatherNotification() async {
    await _notifications.cancel(0);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Agenda atualizações periódicas do clima (a cada 30 minutos)
  Future<void> schedulePeriodicWeatherUpdate() async {
    if (!_initialized) await initialize();

    // Esta funcionalidade requer workmanager para atualizações em background
    // Por enquanto, a atualização será feita quando o app estiver aberto
  }
}
