import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';

class WindChart extends StatelessWidget {
  final List<HourlyWeather> hourlyForecast;
  final WeatherApiService weatherService;

  const WindChart({
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
      return Center(child: Text('Dados de vento não disponíveis'));
    }

    // Converter m/s para km/h
    final windSpeedKmh = next24Hours.map((h) => h.windSpeed * 3.6).toList();
    final windGustKmh = next24Hours.map((h) => h.windGust * 3.6).toList();

    final minWind = windSpeedKmh.reduce((a, b) => a < b ? a : b);
    final maxGust = windGustKmh.reduce((a, b) => a > b ? a : b);
    final avgWind = windSpeedKmh.reduce((a, b) => a + b) / windSpeedKmh.length;
    final avgGust = windGustKmh.reduce((a, b) => a + b) / windGustKmh.length;

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
            'Velocidade do Vento',
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
                child: _buildWindInfoCard(
                  'Rajada Máx',
                  '${maxGust.round()} km/h',
                  const Color(0xFFFFB74D),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildWindInfoCard(
                  'Média Rajadas',
                  '${avgGust.round()} km/h',
                  const Color(0xFFFFA726),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildWindInfoCard(
                  'Vento Mínimo',
                  '${minWind.round()} km/h',
                  const Color(0xFF81C784),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildWindInfoCard(
                  'Média Vento',
                  '${avgWind.round()} km/h',
                  const Color(0xFF66BB6A),
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
                      painter: WindChartPainter(
                        data: next24Hours,
                        windSpeedKmh: windSpeedKmh,
                        windGustKmh: windGustKmh,
                        minWind: minWind,
                        maxGust: maxGust,
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

  Widget _buildWindInfoCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class WindChartPainter extends CustomPainter {
  final List<HourlyWeather> data;
  final List<double> windSpeedKmh;
  final List<double> windGustKmh;
  final double minWind;
  final double maxGust;
  final WeatherApiService weatherService;

  WindChartPainter({
    required this.data,
    required this.windSpeedKmh,
    required this.windGustKmh,
    required this.minWind,
    required this.maxGust,
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

    final minValue = (minWind * 0.8).floorToDouble();
    final maxValue = (maxGust * 1.2).ceilToDouble();
    final valueRange = maxValue - minValue;

    // Paints
    final gustLinePaint = Paint()
      ..color = const Color(0xFFFFB74D)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final speedLinePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final referencePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final gustPointPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.fill;

    final speedPointPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    // Linhas de referência
    for (int i = 0; i <= 5; i++) {
      final y = chartTop + (chartHeight * i / 5);
      canvas.drawLine(Offset(0, y), Offset(width, y), referencePaint);

      final refValue = maxValue - ((maxValue - minValue) * i / 5);
      final refTextPainter = TextPainter(
        text: TextSpan(
          text: '${refValue.round()}',
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

    // Pontos de rajadas e velocidade
    final gustPoints = <Offset>[];
    final speedPoints = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * itemWidth + itemWidth / 2;

      final normalizedGust = (windGustKmh[i] - minValue) / valueRange;
      final yGust = chartBottom - (normalizedGust * chartHeight);
      gustPoints.add(Offset(x, yGust));

      final normalizedSpeed = (windSpeedKmh[i] - minValue) / valueRange;
      final ySpeed = chartBottom - (normalizedSpeed * chartHeight);
      speedPoints.add(Offset(x, ySpeed));
    }

    // Desenhar curvas
    if (gustPoints.length > 1) {
      final path = Path();
      path.moveTo(gustPoints.first.dx, gustPoints.first.dy);

      for (int i = 1; i < gustPoints.length; i++) {
        final cp1x = gustPoints[i - 1].dx + itemWidth / 3;
        final cp1y = gustPoints[i - 1].dy;
        final cp2x = gustPoints[i].dx - itemWidth / 3;
        final cp2y = gustPoints[i].dy;
        path.cubicTo(
            cp1x, cp1y, cp2x, cp2y, gustPoints[i].dx, gustPoints[i].dy);
      }

      canvas.drawPath(path, gustLinePaint);
    }

    if (speedPoints.length > 1) {
      final path = Path();
      path.moveTo(speedPoints.first.dx, speedPoints.first.dy);

      for (int i = 1; i < speedPoints.length; i++) {
        final cp1x = speedPoints[i - 1].dx + itemWidth / 3;
        final cp1y = speedPoints[i - 1].dy;
        final cp2x = speedPoints[i].dx - itemWidth / 3;
        final cp2y = speedPoints[i].dy;
        path.cubicTo(
            cp1x, cp1y, cp2x, cp2y, speedPoints[i].dx, speedPoints[i].dy);
      }

      canvas.drawPath(path, speedLinePaint);
    }

    // Pontos e valores
    for (int i = 0; i < gustPoints.length; i++) {
      if (i % 2 == 0) {
        canvas.drawCircle(gustPoints[i], 5, gustPointPaint);
        canvas.drawCircle(gustPoints[i], 3, Paint()..color = Colors.white);

        final gustTextPainter = TextPainter(
          text: TextSpan(
            text: '${windGustKmh[i].round()}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFE65100),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        gustTextPainter.layout();
        gustTextPainter.paint(
          canvas,
          Offset(
            gustPoints[i].dx - gustTextPainter.width / 2,
            gustPoints[i].dy - 20,
          ),
        );

        canvas.drawCircle(speedPoints[i], 5, speedPointPaint);
        canvas.drawCircle(speedPoints[i], 3, Paint()..color = Colors.white);

        final speedTextPainter = TextPainter(
          text: TextSpan(
            text: '${windSpeedKmh[i].round()}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        speedTextPainter.layout();
        speedTextPainter.paint(
          canvas,
          Offset(
            speedPoints[i].dx - speedTextPainter.width / 2,
            speedPoints[i].dy + 10,
          ),
        );
      }
    }

    // Ícones de direção do vento
    for (int i = 0; i < data.length; i++) {
      if (i % 3 == 0) {
        final iconX = i * itemWidth + itemWidth / 2;
        final iconY = chartTop - 25;

        _drawWindDirectionArrow(
          canvas,
          Offset(iconX, iconY),
          data[i].windDirection.toDouble(),
          const Color(0xFF42A5F5),
        );

        final direction = _getCardinalDirection(data[i].windDirection);
        final dirTextPainter = TextPainter(
          text: TextSpan(
            text: direction,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        dirTextPainter.layout();
        dirTextPainter.paint(
          canvas,
          Offset(iconX - dirTextPainter.width / 2, iconY + 15),
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

    // Legenda
    _drawLegend(canvas, size);
  }

  void _drawWindDirectionArrow(
      Canvas canvas, Offset center, double degrees, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((degrees + 180) * 3.14159 / 180);

    canvas.drawCircle(
        Offset.zero, 12, Paint()..color = Colors.white.withOpacity(0.8));

    final path = Path();
    path.moveTo(0, -8);
    path.lineTo(-4, 4);
    path.lineTo(0, 2);
    path.lineTo(4, 4);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  String _getCardinalDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  void _drawLegend(Canvas canvas, Size size) {
    final legendY = size.height * 0.03;
    final startX = size.width * 0.05;

    final gustLinePaint = Paint()
      ..color = const Color(0xFFFFB74D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(startX, legendY),
      Offset(startX + 25, legendY),
      gustLinePaint,
    );

    final gustText = TextPainter(
      text: TextSpan(
        text: 'Vento - rajadas (km/h)',
        style: TextStyle(fontSize: 9, color: Colors.grey[700]),
      ),
      textDirection: TextDirection.ltr,
    );
    gustText.layout();
    gustText.paint(canvas, Offset(startX + 30, legendY - 6));

    final speedStartX = startX + 160;
    final speedLinePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(speedStartX, legendY),
      Offset(speedStartX + 25, legendY),
      speedLinePaint,
    );

    final speedText = TextPainter(
      text: TextSpan(
        text: 'Vento - média (km/h)',
        style: TextStyle(fontSize: 9, color: Colors.grey[700]),
      ),
      textDirection: TextDirection.ltr,
    );
    speedText.layout();
    speedText.paint(canvas, Offset(speedStartX + 30, legendY - 6));
  }

  @override
  bool shouldRepaint(WindChartPainter oldDelegate) => false;
}
