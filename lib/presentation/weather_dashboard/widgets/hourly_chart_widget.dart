import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';

class HourlyChartWidget extends StatelessWidget {
  final List<HourlyWeather> hourlyForecast;

  const HourlyChartWidget({
    super.key,
    required this.hourlyForecast,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    // Pegar apenas próximas 12 horas para o preview
    final previewData = hourlyForecast.take(12).toList();
    final weatherService = WeatherApiService();

    // Calcular min/max temperatura
    final temps = previewData.map((h) => h.temperature).toList();
    final minTemp = temps.reduce(math.min);
    final maxTemp = temps.reduce(math.max);

    return GestureDetector(
      onTap: () {
        // Navegar para a tela completa
        Navigator.pushNamed(
          context,
          '/hourly-chart',
          arguments: hourlyForecast,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gráfico por horas',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Detalhes',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18.sp,
                      color: const Color(0xFF1976D2),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // Tabs mini
            Row(
              children: [
                _buildMiniTab('Resumo', true),
                SizedBox(width: 2.w),
                _buildMiniTab('Chuva', false),
                SizedBox(width: 2.w),
                _buildMiniTab('Temperatura', false),
                SizedBox(width: 2.w),
                _buildMiniTab('Vento', false),
              ],
            ),

            SizedBox(height: 2.h),

            // Gráfico preview
            SizedBox(
              height: 25.h,
              child: CustomPaint(
                size: Size(double.infinity, 25.h),
                painter: HourlyChartPreviewPainter(
                  data: previewData,
                  minTemp: minTemp,
                  maxTemp: maxTemp,
                  weatherService: weatherService,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTab(String label, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1976D2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }
}

class HourlyChartPreviewPainter extends CustomPainter {
  final List<HourlyWeather> data;
  final double minTemp;
  final double maxTemp;
  final WeatherApiService weatherService;

  HourlyChartPreviewPainter({
    required this.data,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherService,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final itemWidth = width / data.length;

    // Área para o gráfico
    final chartTop = height * 0.1;
    final chartBottom = height * 0.75;
    final chartHeight = chartBottom - chartTop;

    // Paint para a linha de temperatura
    final linePaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Paint para o preenchimento
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE57373).withOpacity(0.25),
          const Color(0xFFE57373).withOpacity(0.03),
        ],
      ).createShader(Rect.fromLTWH(0, chartTop, width, chartHeight));

    // Calcular pontos
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * itemWidth + itemWidth / 2;
      final normalizedTemp =
          (data[i].temperature - minTemp) / (maxTemp - minTemp);
      final y = chartBottom - (normalizedTemp * chartHeight);
      points.add(Offset(x, y));
    }

    // Desenhar preenchimento
    if (points.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, chartBottom);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final cp1x = points[i - 1].dx + itemWidth / 3;
        final cp1y = points[i - 1].dy;
        final cp2x = points[i].dx - itemWidth / 3;
        final cp2y = points[i].dy;
        fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
      }

      fillPath.lineTo(points.last.dx, chartBottom);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // Desenhar curva
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final cp1x = points[i - 1].dx + itemWidth / 3;
        final cp1y = points[i - 1].dy;
        final cp2x = points[i].dx - itemWidth / 3;
        final cp2y = points[i].dy;
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
      }

      canvas.drawPath(path, linePaint);
    }

    // Desenhar ícones e temperaturas
    for (int i = 0; i < data.length; i++) {
      if (i % 2 == 0) {
        // Ícone do clima (círculo como placeholder)
        final iconPaint = Paint()
          ..color = _getIconColor(data[i].icon)
          ..style = PaintingStyle.fill;

        final iconX = i * itemWidth + itemWidth / 2;
        final iconY = chartTop - 20;
        canvas.drawCircle(Offset(iconX, iconY), 8, iconPaint);

        // Temperatura
        final tempPainter = TextPainter(
          text: TextSpan(
            text: '${data[i].temperature.round()}°',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        tempPainter.layout();
        tempPainter.paint(
          canvas,
          Offset(
            points[i].dx - tempPainter.width / 2,
            points[i].dy - 18,
          ),
        );

        // Hora
        final hourPainter = TextPainter(
          text: TextSpan(
            text: '${data[i].time.hour.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        hourPainter.layout();
        hourPainter.paint(
          canvas,
          Offset(
            iconX - hourPainter.width / 2,
            height * 0.85,
          ),
        );
      }
    }

    // Legenda
    _drawLegend(canvas, size);
  }

  void _drawLegend(Canvas canvas, Size size) {
    final legendY = size.height * 0.92;

    // Temperatura (linha)
    final linePaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.15, legendY),
      Offset(size.width * 0.15 + 15, legendY),
      linePaint,
    );

    final tempText = TextPainter(
      text: TextSpan(
        text: 'Temperatura (°C)',
        style: TextStyle(fontSize: 8, color: Colors.grey[700]),
      ),
      textDirection: TextDirection.ltr,
    );
    tempText.layout();
    tempText.paint(canvas, Offset(size.width * 0.15 + 20, legendY - 6));

    // Chuva (quadrado)
    final rainPaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, legendY - 5, 10, 10),
      rainPaint,
    );

    final rainText = TextPainter(
      text: TextSpan(
        text: 'Chuva (mm)',
        style: TextStyle(fontSize: 8, color: Colors.grey[700]),
      ),
      textDirection: TextDirection.ltr,
    );
    rainText.layout();
    rainText.paint(canvas, Offset(size.width * 0.55 + 15, legendY - 6));
  }

  Color _getIconColor(String iconCode) {
    if (iconCode.contains('01')) return const Color(0xFFFFB74D); // Sol
    if (iconCode.contains('02')) return const Color(0xFFFDD835); // Sol/Nuvem
    if (iconCode.contains('03') || iconCode.contains('04')) {
      return const Color(0xFF90CAF9); // Nuvem
    }
    if (iconCode.contains('09') || iconCode.contains('10')) {
      return const Color(0xFF42A5F5); // Chuva
    }
    if (iconCode.contains('11')) return const Color(0xFF7E57C2); // Tempestade
    if (iconCode.contains('13')) return const Color(0xFF81D4FA); // Neve
    if (iconCode.contains('50')) return const Color(0xFF78909C); // Neblina
    return const Color(0xFF42A5F5);
  }

  @override
  bool shouldRepaint(HourlyChartPreviewPainter oldDelegate) => false;
}
