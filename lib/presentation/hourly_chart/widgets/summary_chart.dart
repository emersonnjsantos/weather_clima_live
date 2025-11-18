import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';

class SummaryChart extends StatelessWidget {
  final List<HourlyWeather> hourlyForecast;
  final WeatherApiService weatherService;

  const SummaryChart({
    Key? key,
    required this.hourlyForecast,
    required this.weatherService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final next24Hours = hourlyForecast
        .where((h) =>
            h.time.isAfter(now) &&
            h.time.isBefore(now.add(const Duration(hours: 24))))
        .toList();

    if (next24Hours.isEmpty) {
      return Center(
        child: Text('Dados não disponíveis'),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          Text(
            'Resumo - Próximas 24h',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: next24Hours.length * 60.0,
                    height: constraints.maxHeight,
                    child: CustomPaint(
                      size: Size(
                          next24Hours.length * 60.0, constraints.maxHeight),
                      painter: SummaryChartPainter(
                        data: next24Hours,
                        weatherService: weatherService,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryChartPainter extends CustomPainter {
  final List<HourlyWeather> data;
  final WeatherApiService weatherService;

  SummaryChartPainter({
    required this.data,
    required this.weatherService,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final itemWidth = width / data.length;

    // Temperaturas
    final temps = data.map((h) => h.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);

    // Área para gráficos
    final tempChartTop = height * 0.1;
    final tempChartBottom = height * 0.45;
    final tempChartHeight = tempChartBottom - tempChartTop;

    final rainChartTop = height * 0.55;
    final rainChartBottom = height * 0.85;
    final rainChartHeight = rainChartBottom - rainChartTop;

    // Paint para linha de temperatura
    final tempLinePaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Paint para barras de chuva
    final rainBarPaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.fill;

    // Desenhar curva de temperatura
    final tempPoints = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * itemWidth + itemWidth / 2;
      final normalizedTemp =
          (data[i].temperature - minTemp) / (maxTemp - minTemp);
      final y = tempChartBottom - (normalizedTemp * tempChartHeight);
      tempPoints.add(Offset(x, y));
    }

    if (tempPoints.length > 1) {
      final path = Path();
      path.moveTo(tempPoints.first.dx, tempPoints.first.dy);

      for (int i = 1; i < tempPoints.length; i++) {
        final cp1x = tempPoints[i - 1].dx + itemWidth / 3;
        final cp1y = tempPoints[i - 1].dy;
        final cp2x = tempPoints[i].dx - itemWidth / 3;
        final cp2y = tempPoints[i].dy;
        path.cubicTo(
            cp1x, cp1y, cp2x, cp2y, tempPoints[i].dx, tempPoints[i].dy);
      }

      canvas.drawPath(path, tempLinePaint);

      // Desenhar pontos e valores
      for (int i = 0; i < tempPoints.length; i++) {
        if (i % 2 == 0) {
          canvas.drawCircle(
            tempPoints[i],
            4,
            Paint()..color = const Color(0xFFD32F2F),
          );

          final textPainter = TextPainter(
            text: TextSpan(
              text: '${data[i].temperature.round()}°',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              tempPoints[i].dx - textPainter.width / 2,
              tempPoints[i].dy - 20,
            ),
          );
        }
      }
    }

    // Desenhar barras de precipitação
    final maxPrecip =
        data.map((h) => h.precipitation).reduce((a, b) => a > b ? a : b);
    for (int i = 0; i < data.length; i++) {
      final barWidth = itemWidth * 0.6;
      final barHeight =
          (data[i].precipitation / (maxPrecip > 0 ? maxPrecip : 100)) *
              rainChartHeight;
      final x = i * itemWidth + (itemWidth - barWidth) / 2;
      final y = rainChartBottom - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        rainBarPaint,
      );

      // Mostrar porcentagem
      if (i % 2 == 0 && data[i].precipitation > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${data[i].precipitation}%',
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            i * itemWidth + itemWidth / 2 - textPainter.width / 2,
            y - 16,
          ),
        );
      }
    }

    // Desenhar régua de tempo
    final timePainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      if (i % 3 == 0) {
        final hour = data[i].time.hour.toString().padLeft(2, '0');
        timePainter.text = TextSpan(
          text: hour,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        );
        timePainter.layout();
        timePainter.paint(
          canvas,
          Offset(
            i * itemWidth + itemWidth / 2 - timePainter.width / 2,
            height * 0.9,
          ),
        );
      }
    }

    // Labels
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    labelPainter.text = TextSpan(
      text: 'Temperatura',
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
        fontWeight: FontWeight.w600,
      ),
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(10, tempChartTop - 25));

    labelPainter.text = TextSpan(
      text: 'Precipitação',
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
        fontWeight: FontWeight.w600,
      ),
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(10, rainChartTop - 25));
  }

  @override
  bool shouldRepaint(SummaryChartPainter oldDelegate) => false;
}
