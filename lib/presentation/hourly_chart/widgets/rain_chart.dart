import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';

class RainChart extends StatelessWidget {
  final List<HourlyWeather> hourlyForecast;
  final WeatherApiService weatherService;

  const RainChart({
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
      return Center(child: Text('Dados de chuva não disponíveis'));
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
            'Dados de Chuva',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Nebulosidade', Colors.grey, false),
              _buildLegendItem('Pressão (mb)', const Color(0xFF66BB6A), true),
              _buildLegendItem('Chuva (mm)', const Color(0xFF42A5F5), false),
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
                      painter: RainChartPainter(
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

  Widget _buildLegendItem(String label, Color color, bool isLine) {
    return Row(
      children: [
        if (isLine)
          Container(
            width: 20,
            height: 3,
            color: color,
          )
        else
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(fontSize: 9.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

class RainChartPainter extends CustomPainter {
  final List<HourlyWeather> data;
  final WeatherApiService weatherService;

  RainChartPainter({
    required this.data,
    required this.weatherService,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final itemWidth = width / data.length;

    final chartTop = height * 0.08;
    final chartBottom = height * 0.82;
    final chartHeight = chartBottom - chartTop;

    // Paints
    final cloudFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[300]!.withOpacity(0.5),
          Colors.grey[300]!.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, chartTop, width, chartHeight));

    final pressurePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rainPaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.fill;

    final referencePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Linhas de referência
    for (int i = 0; i <= 4; i++) {
      final y = chartTop + (chartHeight * i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), referencePaint);
    }

    // Nebulosidade
    final cloudPoints = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * itemWidth + itemWidth / 2;
      double cloudiness = _getCloudiness(data[i].icon);
      final y = chartTop + (chartHeight * (1 - cloudiness / 100));
      cloudPoints.add(Offset(x, y));
    }

    if (cloudPoints.length > 1) {
      final cloudPath = Path();
      cloudPath.moveTo(cloudPoints.first.dx, chartBottom);
      cloudPath.lineTo(cloudPoints.first.dx, cloudPoints.first.dy);

      for (int i = 1; i < cloudPoints.length; i++) {
        final cp1x = cloudPoints[i - 1].dx + itemWidth / 3;
        final cp1y = cloudPoints[i - 1].dy;
        final cp2x = cloudPoints[i].dx - itemWidth / 3;
        final cp2y = cloudPoints[i].dy;
        cloudPath.cubicTo(
            cp1x, cp1y, cp2x, cp2y, cloudPoints[i].dx, cloudPoints[i].dy);
      }

      cloudPath.lineTo(cloudPoints.last.dx, chartBottom);
      cloudPath.close();
      canvas.drawPath(cloudPath, cloudFillPaint);
    }

    // Pressão
    final pressurePoints = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * itemWidth + itemWidth / 2;
      final pressure = 1014 + (data[i].temperature - 25) * 0.1;
      final normalizedPressure = (pressure - 1010) / 6;
      final y = chartTop + (chartHeight * (1 - normalizedPressure));
      pressurePoints.add(Offset(x, y));
    }

    if (pressurePoints.length > 1) {
      final pressurePath = Path();
      pressurePath.moveTo(pressurePoints.first.dx, pressurePoints.first.dy);

      for (int i = 1; i < pressurePoints.length; i++) {
        final cp1x = pressurePoints[i - 1].dx + itemWidth / 3;
        final cp1y = pressurePoints[i - 1].dy;
        final cp2x = pressurePoints[i].dx - itemWidth / 3;
        final cp2y = pressurePoints[i].dy;
        pressurePath.cubicTo(
            cp1x, cp1y, cp2x, cp2y, pressurePoints[i].dx, pressurePoints[i].dy);
      }

      canvas.drawPath(pressurePath, pressurePaint);
    }

    // Valores de pressão
    final pressureTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < pressurePoints.length; i++) {
      if (i % 3 == 0) {
        final pressure = 1014 + (data[i].temperature - 25) * 0.1;
        pressureTextPainter.text = TextSpan(
          text: pressure.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        );
        pressureTextPainter.layout();
        pressureTextPainter.paint(
          canvas,
          Offset(
            pressurePoints[i].dx - pressureTextPainter.width / 2,
            pressurePoints[i].dy - 18,
          ),
        );
      }
    }

    // Barras de chuva
    final maxRainHeight = chartHeight * 0.4;
    for (int i = 0; i < data.length; i++) {
      double rainMm = _getRainAmount(data[i].icon);

      if (rainMm > 0) {
        final x = i * itemWidth + itemWidth / 2;
        final barWidth = itemWidth * 0.4;
        final barHeight = (rainMm / 5) * maxRainHeight;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - barWidth / 2,
            chartBottom - barHeight,
            barWidth,
            barHeight,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, rainPaint);

        if (barHeight > 10) {
          final rainTextPainter = TextPainter(
            text: TextSpan(
              text: rainMm.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          );
          rainTextPainter.layout();
          rainTextPainter.paint(
            canvas,
            Offset(
              x - rainTextPainter.width / 2,
              chartBottom - barHeight - 15,
            ),
          );
        }
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

  double _getCloudiness(String iconCode) {
    if (iconCode.contains('01')) return 10;
    if (iconCode.contains('02')) return 30;
    if (iconCode.contains('03')) return 60;
    if (iconCode.contains('04')) return 90;
    if (iconCode.contains('09') || iconCode.contains('10')) return 80;
    if (iconCode.contains('11')) return 95;
    if (iconCode.contains('50')) return 70;
    return 50;
  }

  double _getRainAmount(String iconCode) {
    if (iconCode.contains('09')) return 2.5;
    if (iconCode.contains('10')) return 1.5;
    if (iconCode.contains('11')) return 4.0;
    return 0.0;
  }

  @override
  bool shouldRepaint(RainChartPainter oldDelegate) => false;
}
