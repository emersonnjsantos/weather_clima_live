import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import '../services/weather_api_service.dart';

class GpsLocationWidget extends StatefulWidget {
  const GpsLocationWidget({Key? key}) : super(key: key);

  @override
  State<GpsLocationWidget> createState() => _GpsLocationWidgetState();
}

class _GpsLocationWidgetState extends State<GpsLocationWidget>
    with WidgetsBindingObserver {
  bool _isGPSEnabled = false;
  String _currentCity = 'Localizando...';
  String _currentState = '';
  String _temperature = '--°';
  final WeatherApiService _weatherService = WeatherApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkGPSStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detecta quando o app volta ao primeiro plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkGPSStatus();
    }
  }

  // Verifica se o GPS está ativado
  Future<void> _checkGPSStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;

      setState(() {
        _isGPSEnabled = serviceEnabled;
      });

      if (serviceEnabled) {
        await _getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Erro ao verificar GPS: $e');
      if (!mounted) return;
      setState(() {
        _isGPSEnabled = false;
      });
    }
  }

  // Obtém a localização atual do dispositivo
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _currentCity = 'Permissão negada';
          _currentState = 'Ative nas configurações';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Geocodificação reversa para obter cidade e estado
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Buscar dados climáticos da localização
      final weatherData = await _weatherService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      // Usar nome da cidade do WeatherData (mais confiável)
      String city = weatherData.location;
      String state = '';

      // Tentar obter estado da geocodificação
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        state = place.administrativeArea ?? '';

        // Debug
        debugPrint('Placemark completo: $place');
        debugPrint('locality: ${place.locality}');
        debugPrint('administrativeArea: ${place.administrativeArea}');
        debugPrint('weatherData.location: ${weatherData.location}');
      }

      setState(() {
        _currentCity = city;
        _currentState = state;
        _temperature = '${weatherData.temperature.round()}°';
      });

      debugPrint('Cidade definida: $city');
      debugPrint('Estado definido: $state');
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      if (!mounted) return;
      setState(() {
        _currentCity = 'Erro ao localizar';
        _currentState = 'Tente novamente';
      });
    }
  }

  // Exibe diálogo de permissão de localização
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.grey[100],
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Para uma experiência melhor, o dispositivo precisa usar a Precisão de Local',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 20),

                // Subtítulo
                Text(
                  'Estas configurações precisam estar ativadas:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16),

                // Item 1 - Localização do dispositivo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Localização do dispositivo',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Item 2 - Precisão de Local
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Com o recurso Precisão de Local, apps e serviços podem acessar dados ainda mais precisos. Para isso, o Google analisa periodicamente os sensores e sinais sem fio do seu dispositivo para entender onde essas redes estão. As informações não identificam você e são usadas para aprimorar a precisão e os serviços que você usa.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Botões
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isGPSEnabled = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Agora não',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        setState(() {
                          _isGPSEnabled = true;
                        });
                        await _getCurrentLocation();

                        if (!mounted) return;
                        Fluttertoast.showToast(
                          msg: "GPS ativado",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 14.sp,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Ativar',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ativa/Desativa o GPS
  Future<void> _toggleGPS(bool value) async {
    if (value) {
      // Exibe o diálogo de permissão
      _showLocationPermissionDialog();
    } else {
      setState(() {
        _isGPSEnabled = false;
      });

      Fluttertoast.showToast(
        msg: "GPS desativado",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[700]!,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Linha com switch GPS
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(
                _isGPSEnabled ? Icons.location_on : Icons.navigation_outlined,
                color: _isGPSEnabled ? Colors.blue : Colors.grey[700],
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  _isGPSEnabled ? _currentCity : 'Ative o GPS',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Switch(
                value: _isGPSEnabled,
                onChanged: _toggleGPS,
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),
        // Linha com localização e temperatura
        if (_isGPSEnabled)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.cloud_outlined, color: Colors.grey[600]),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentCity,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (_currentState.isNotEmpty)
                        Text(
                          _currentState,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _temperature,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
