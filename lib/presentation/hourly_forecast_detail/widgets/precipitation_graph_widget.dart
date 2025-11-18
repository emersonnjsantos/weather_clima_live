import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrecipitationGraphWidget extends StatefulWidget {
  final List<Map<String, dynamic>> hourlyData;
  final Function(int) onHourSelected;
  final int selectedIndex;

  const PrecipitationGraphWidget({
    super.key,
    required this.hourlyData,
    required this.onHourSelected,
    required this.selectedIndex,
  });

  @override
  State<PrecipitationGraphWidget> createState() =>
      _PrecipitationGraphWidgetState();
}

class _PrecipitationGraphWidgetState extends State<PrecipitationGraphWidget> {
  double _scaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: EdgeInsets.all(4.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Precipitação (%)',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface)),
                Row(children: [
                  CustomIconWidget(
                      iconName: 'zoom_in',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20),
                  SizedBox(width: 2.w),
                  Text('Toque para ampliar',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme
                              .lightTheme.colorScheme.onSurfaceVariant)),
                ]),
              ]),
              SizedBox(height: 2.h),
              Expanded(
                  child: GestureDetector(
                      onScaleStart: (details) {
                        // Manipular início de escala
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          _scaleFactor = details.scale.clamp(1.0, 3.0);
                        });
                      },
                      onScaleEnd: (details) {
                        // Manipular fim de escala
                      },
                      child: Transform.scale(
                          scale: _scaleFactor,
                          child: BarChart(BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(
                                  enabled: true,
                                  touchCallback:
                                      (FlTouchEvent event, barTouchResponse) {
                                    if (event is FlTapUpEvent &&
                                        barTouchResponse != null) {
                                      final touchedIndex = barTouchResponse
                                          .spot?.touchedBarGroupIndex;
                                      if (touchedIndex != null &&
                                          touchedIndex <
                                              widget.hourlyData.length) {
                                        widget.onHourSelected(touchedIndex);
                                      }
                                    }
                                  },
                                  touchTooltipData: BarTouchTooltipData(
                                      tooltipRoundedRadius: 8,
                                      tooltipPadding: EdgeInsets.symmetric(
                                          horizontal: 3.w, vertical: 1.h),
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        final hourData =
                                            widget.hourlyData[groupIndex];
                                        return BarTooltipItem(
                                            '${hourData["time"]}\n${hourData["precipitation"]}%\n${hourData["condition"]}',
                                            AppTheme.lightTheme.textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: AppTheme
                                                            .lightTheme
                                                            .colorScheme
                                                            .onInverseSurface) ??
                                                const TextStyle());
                                      })),
                              titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget:
                                              (double value, TitleMeta meta) {
                                            if (value.toInt() <
                                                widget.hourlyData.length) {
                                              final hourData = widget
                                                  .hourlyData[value.toInt()];
                                              return Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 1.h),
                                                  child: Text(
                                                      hourData["time"]
                                                          as String,
                                                      style: AppTheme.lightTheme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                              color: AppTheme
                                                                  .lightTheme
                                                                  .colorScheme
                                                                  .onSurfaceVariant)));
                                            }
                                            return const Text('');
                                          },
                                          reservedSize: 30)),
                                  leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 20,
                                          getTitlesWidget:
                                              (double value, TitleMeta meta) {
                                            return Text('${value.toInt()}%',
                                                style: AppTheme.lightTheme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                        color: AppTheme
                                                            .lightTheme
                                                            .colorScheme
                                                            .onSurfaceVariant));
                                          },
                                          reservedSize: 40))),
                              borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline
                                          .withValues(alpha: 0.2))),
                              gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 20,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                        color: AppTheme
                                            .lightTheme.colorScheme.outline
                                            .withValues(alpha: 0.1),
                                        strokeWidth: 1);
                                  }),
                              barGroups: _buildBarGroups()))))),
              SizedBox(height: 1.h),
              _buildLegend(),
            ])));
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.hourlyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final precipitation = (data["precipitation"] as int).toDouble();
      final isSelected = index == widget.selectedIndex;

      return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
                toY: precipitation,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : _getPrecipitationColor(precipitation),
                width: isSelected ? 20 : 16,
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _getPrecipitationColor(precipitation)
                          .withValues(alpha: 0.3),
                      _getPrecipitationColor(precipitation),
                    ])),
          ],
          showingTooltipIndicators: isSelected ? [0] : []);
    }).toList();
  }

  Color _getPrecipitationColor(double precipitation) {
    if (precipitation >= 80) {
      return AppTheme.weatherStormLight;
    } else if (precipitation >= 50) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (precipitation >= 20) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else {
      return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.6);
    }
  }

  Widget _buildLegend() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _buildLegendItem('Baixa (0-20%)',
          AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.6)),
      _buildLegendItem(
          'Moderada (20-50%)', AppTheme.lightTheme.colorScheme.secondary),
      _buildLegendItem(
          'Alta (50-80%)', AppTheme.lightTheme.colorScheme.primary),
      _buildLegendItem('Muito Alta (80%+)', AppTheme.weatherStormLight),
    ]);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      SizedBox(width: 1.w),
      Text(label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
    ]);
  }
}
