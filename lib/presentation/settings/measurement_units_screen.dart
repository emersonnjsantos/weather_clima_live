import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MeasurementUnitsScreen extends StatefulWidget {
  const MeasurementUnitsScreen({super.key});

  @override
  State<MeasurementUnitsScreen> createState() => _MeasurementUnitsScreenState();
}

class _MeasurementUnitsScreenState extends State<MeasurementUnitsScreen> {
  String _temperatureUnit = 'Celsius (°C)';
  String _speedUnit = 'Quilômetros/hora (km/h)';
  String _rainUnit = 'Milímetros (mm)';
  String _distanceUnit = 'Sistema internacional: km, m, cm...';
  String _pressureUnit = 'Milibares (mb)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Unidades de medição',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        children: [
          // Temperatura
          _buildUnitCard(
            icon: Icons.thermostat_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Temperatura',
            currentValue: _temperatureUnit,
            onTap: () {
              _showTemperatureOptions();
            },
          ),

          SizedBox(height: 1.5.h),

          // Velocidade
          _buildUnitCard(
            icon: Icons.air,
            iconColor: const Color(0xFF1E88E5),
            title: 'Velocidade',
            currentValue: _speedUnit,
            onTap: () {
              _showSpeedOptions();
            },
          ),

          SizedBox(height: 1.5.h),

          // Chuva
          _buildUnitCard(
            icon: Icons.umbrella_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Chuva',
            currentValue: _rainUnit,
            onTap: () {
              _showRainOptions();
            },
          ),

          SizedBox(height: 1.5.h),

          // Altura e distância
          _buildUnitCard(
            icon: Icons.terrain,
            iconColor: const Color(0xFF1E88E5),
            title: 'Altura e distância',
            currentValue: _distanceUnit,
            onTap: () {
              _showDistanceOptions();
            },
          ),

          SizedBox(height: 1.5.h),

          // Pressão
          _buildUnitCard(
            icon: Icons.compress,
            iconColor: const Color(0xFF1E88E5),
            title: 'Pressão',
            currentValue: _pressureUnit,
            onTap: () {
              _showPressureOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.grey.withOpacity(0.2),
        highlightColor: Colors.grey.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      currentValue,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemperatureOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Temperatura',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Celsius (°C)', _temperatureUnit, (value) {
                setState(() => _temperatureUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Fahrenheit (°F)', _temperatureUnit, (value) {
                setState(() => _temperatureUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Kelvin (K)', _temperatureUnit, (value) {
                setState(() => _temperatureUnit = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Velocidade',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Quilômetros/hora (km/h)', _speedUnit, (value) {
                setState(() => _speedUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Milhas/hora (mph)', _speedUnit, (value) {
                setState(() => _speedUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Metros/segundo (m/s)', _speedUnit, (value) {
                setState(() => _speedUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Nós (kt)', _speedUnit, (value) {
                setState(() => _speedUnit = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showRainOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Chuva',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Milímetros (mm)', _rainUnit, (value) {
                setState(() => _rainUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Polegadas (in)', _rainUnit, (value) {
                setState(() => _rainUnit = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showDistanceOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Altura e distância',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                  'Sistema internacional: km, m, cm...', _distanceUnit,
                  (value) {
                setState(() => _distanceUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Sistema imperial: mi, ft, in...', _distanceUnit,
                  (value) {
                setState(() => _distanceUnit = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPressureOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Pressão',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Milibares (mb)', _pressureUnit, (value) {
                setState(() => _pressureUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Hectopascais (hPa)', _pressureUnit, (value) {
                setState(() => _pressureUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Polegadas de mercúrio (inHg)', _pressureUnit,
                  (value) {
                setState(() => _pressureUnit = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Milímetros de mercúrio (mmHg)', _pressureUnit,
                  (value) {
                setState(() => _pressureUnit = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
      String label, String currentValue, Function(String) onSelected) {
    final isSelected = label == currentValue;
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: currentValue,
      activeColor: const Color(0xFF1E88E5),
      selected: isSelected,
      onChanged: (value) {
        if (value != null) {
          onSelected(value);
        }
      },
    );
  }
}
