import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../services/weather_api_service.dart';

class WeatherMapsPreviewWidget extends StatefulWidget {
  const WeatherMapsPreviewWidget({super.key});

  @override
  State<WeatherMapsPreviewWidget> createState() =>
      _WeatherMapsPreviewWidgetState();
}

class _WeatherMapsPreviewWidgetState extends State<WeatherMapsPreviewWidget> {
  late WebViewController _controller;
  final WeatherApiService _weatherService = WeatherApiService();
  bool _isLoading = true;

  // Localização padrão (Curitiba)
  double _lat = -25.4284;
  double _lon = -49.2733;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadCurrentLocation();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_getWindyUrl()));
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final position = await _weatherService.getCurrentLocation();
      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
      });
      _controller.loadRequest(Uri.parse(_getWindyUrl()));
    } catch (e) {
      debugPrint('Usando localização padrão: $e');
    }
  }

  String _getWindyUrl() {
    // URL do Windy.com com overlay de nuvens/chuva
    return 'https://embed.windy.com/embed2.html'
        '?lat=$_lat'
        '&lon=$_lon'
        '&detailLat=$_lat'
        '&detailLon=$_lon'
        '&zoom=6'
        '&level=surface'
        '&overlay=rain'
        '&product=ecmwf'
        '&menu='
        '&message='
        '&marker='
        '&calendar=now'
        '&pressure='
        '&type=map'
        '&location=coordinates'
        '&detail='
        '&metricWind=default'
        '&metricTemp=default'
        '&radarRange=-1';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(context, '/weather-maps');
          },
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mapas de Previsão',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Mapas',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF1976D2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.sp,
                          color: const Color(0xFF1976D2),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Preview do mapa REAL com WebView
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // WebView com mapa real do Windy
                      SizedBox(
                        height: 25.h,
                        child: WebViewWidget(
                          controller: _controller,
                        ),
                      ),

                      // Loading overlay
                      if (_isLoading)
                        Container(
                          height: 25.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue[100]!,
                                Colors.blue[200]!,
                                Colors.blue[300]!,
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),

                      // Badge no canto superior esquerdo
                      Positioned(
                        top: 2.w,
                        left: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud,
                                size: 4.w,
                                color: const Color(0xFF1976D2),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Nuvens, chuva e neve',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),

                // Ícones de tipos de mapas disponíveis
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMapTypeIcon(
                      Icons.thermostat,
                      'Temperatura',
                      Colors.orange,
                    ),
                    _buildMapTypeIcon(
                      Icons.air,
                      'Vento',
                      Colors.green,
                    ),
                    _buildMapTypeIcon(
                      Icons.cloud,
                      'Nuvens',
                      Colors.grey,
                    ),
                    _buildMapTypeIcon(
                      Icons.water_drop,
                      'Chuva',
                      Colors.blue,
                    ),
                    _buildMapTypeIcon(
                      Icons.compress,
                      'Pressão',
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapTypeIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 5.w,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
