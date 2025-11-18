import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';

class TemperatureChart extends StatelessWidget {
  final List<HourlyWeather> hourlyForecast;
  final WeatherApiService weatherService;

  const TemperatureChart({
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
      return Center(child: Text('Dados de temperatura não disponíveis'));
    }

    // Calcular estatísticas
    final temps = next24Hours.map((h) => h.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final avgTemp = temps.reduce((a, b) => a + b) / temps.length;

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
            'Temperatura',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildTempInfoCard(
                  'Mínima',
                  '${minTemp.round()}°C',
                  const Color(0xFF42A5F5),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildTempInfoCard(
                  'Máxima',
                  '${maxTemp.round()}°C',
                  const Color(0xFFE57373),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildTempInfoCard(
                  'Média',
                  '${avgTemp.round()}°C',
                  const Color(0xFFFFB74D),
                ),
              ),
            ],
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
                      painter: TemperatureChartPainter(
                        data: next24Hours,
                        minTemp: minTemp,
                        maxTemp: maxTemp,
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

  Widget _buildTempInfoCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class TemperatureChartPainter extends CustomPainter {
  final List<HourlyWeather> data;
  final double minTemp;
  final double maxTemp;
  final WeatherApiService weatherService;

  TemperatureChartPainter({
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

    final chartTop = height * 0.12;
    final chartBottom = height * 0.78;
    final chartHeight = chartBottom - chartTop;

    // Paints
    final tempLinePaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tempFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE57373).withOpacity(0.35),
          const Color(0xFFE57373).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, chartTop, width, chartHeight));

    final feelsLikeFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFAB91).withOpacity(0.2),
          const Color(0xFFFFAB91).withOpacity(0.03),
        ],
      ).createShader(Rect.fromLTWH(0, chartTop, width, chartHeight));

    final feelsLikePaint = Paint()
      ..color = const Color(0xFFFF7043)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final referencePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    // Linhas de referência
    for (int i = 0; i <= 5; i++) {
      final y = chartTop + (chartHeight * i / 5);
      canvas.drawLine(Offset(0, y), Offset(width, y), referencePaint);

      final refTemp = maxTemp - ((maxTemp - minTemp) * i / 5);
      final refTextPainter = TextPainter(
        text: TextSpan(
          text: '${refTemp.round()}°',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      refTextPainter.layout();
      refTextPainter.paint(canvas, Offset(5, y - 12));
    }

    // Pontos de temperatura e sensação térmica
    final tempPoints = <Offset>[];
    final feelsLikePoints = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * itemWidth + itemWidth / 2;

      final normalizedTemp =
          (data[i].temperature - minTemp) / (maxTemp - minTemp);
      final yTemp = chartBottom - (normalizedTemp * chartHeight);
      tempPoints.add(Offset(x, yTemp));

      final normalizedFeels =
          (data[i].feelsLike - minTemp) / (maxTemp - minTemp);
      final yFeels = chartBottom - (normalizedFeels * chartHeight);
      feelsLikePoints.add(Offset(x, yFeels));
    }

    // Desenhar preenchimentos
    if (feelsLikePoints.length > 1) {
      final feelsPath = Path();
      feelsPath.moveTo(feelsLikePoints.first.dx, chartBottom);
      feelsPath.lineTo(feelsLikePoints.first.dx, feelsLikePoints.first.dy);

      for (int i = 1; i < feelsLikePoints.length; i++) {
        final cp1x = feelsLikePoints[i - 1].dx + itemWidth / 3;
        final cp1y = feelsLikePoints[i - 1].dy;
        final cp2x = feelsLikePoints[i].dx - itemWidth / 3;
        final cp2y = feelsLikePoints[i].dy;
        feelsPath.cubicTo(cp1x, cp1y, cp2x, cp2y, feelsLikePoints[i].dx,
            feelsLikePoints[i].dy);
      }

      feelsPath.lineTo(feelsLikePoints.last.dx, chartBottom);
      feelsPath.close();
      canvas.drawPath(feelsPath, feelsLikeFillPaint);
    }

    if (tempPoints.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(tempPoints.first.dx, chartBottom);
      fillPath.lineTo(tempPoints.first.dx, tempPoints.first.dy);

      for (int i = 1; i < tempPoints.length; i++) {
        final cp1x = tempPoints[i - 1].dx + itemWidth / 3;
        final cp1y = tempPoints[i - 1].dy;
        final cp2x = tempPoints[i].dx - itemWidth / 3;
        final cp2y = tempPoints[i].dy;
        fillPath.cubicTo(
            cp1x, cp1y, cp2x, cp2y, tempPoints[i].dx, tempPoints[i].dy);
      }

      fillPath.lineTo(tempPoints.last.dx, chartBottom);
      fillPath.close();
      canvas.drawPath(fillPath, tempFillPaint);
    }

    // Desenhar linhas
    if (feelsLikePoints.length > 1) {
      final feelsPath = Path();
      feelsPath.moveTo(feelsLikePoints.first.dx, feelsLikePoints.first.dy);

      for (int i = 1; i < feelsLikePoints.length; i++) {
        final cp1x = feelsLikePoints[i - 1].dx + itemWidth / 3;
        final cp1y = feelsLikePoints[i - 1].dy;
        final cp2x = feelsLikePoints[i].dx - itemWidth / 3;
        final cp2y = feelsLikePoints[i].dy;
        feelsPath.cubicTo(cp1x, cp1y, cp2x, cp2y, feelsLikePoints[i].dx,
            feelsLikePoints[i].dy);
      }

      _drawDashedPath(canvas, feelsPath, feelsLikePaint, 8, 5);
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
    }

    // Pontos e valores
    for (int i = 0; i < tempPoints.length; i++) {
      if (i % 2 == 0) {
        canvas.drawCircle(tempPoints[i], 5, pointPaint);
        canvas.drawCircle(tempPoints[i], 3, Paint()..color = Colors.white);

        final tempTextPainter = TextPainter(
          text: TextSpan(
            text: '${data[i].temperature.round()}°',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tempTextPainter.layout();
        tempTextPainter.paint(
          canvas,
          Offset(
            tempPoints[i].dx - tempTextPainter.width / 2,
            tempPoints[i].dy - 22,
          ),
        );
      }
    }

    // Régua de tempo
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
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        );
        timePainter.layout();
        timePainter.paint(
          canvas,
          Offset(
            i * itemWidth + itemWidth / 2 - timePainter.width / 2,
            height * 0.88,
          ),
        );
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth,
      double dashSpace) {
    final metric = path.computeMetrics().first;
    double distance = 0.0;
    bool draw = true;

    while (distance < metric.length) {
      final length = draw ? dashWidth : dashSpace;
      final segment = metric.extractPath(distance, distance + length);
      if (draw) {
        canvas.drawPath(segment, paint);
      }
      distance += length;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(TemperatureChartPainter oldDelegate) => false;
}
