import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  // Estados dos switches
  bool _statusBarTemperature = true;
  bool _tomorrowHighlights = true;
  bool _nextHours = true;
  bool _meteorologicalAlerts = true;

  // Localização selecionada
  String _selectedLocation =
      'R. Henrique Ghellere, 1559 - São José do Itavó, Itaipulândia - PR, 85880-000, Brasil, São Paulo';

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
          'Centro de notificações',
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
          // Temperatura na barra de status
          _buildNotificationCard(
            icon: Icons.thermostat_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Temperatura na barra de status',
            subtitle: _selectedLocation,
            value: _statusBarTemperature,
            onChanged: (value) {
              setState(() => _statusBarTemperature = value);
            },
          ),

          SizedBox(height: 1.5.h),

          // Localizações
          _buildLocationCard(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFF00BCD4),
            title: 'Localizações',
            subtitle: _selectedLocation,
            onTap: () {
              // Abrir seletor de localização
              _showLocationPicker();
            },
          ),

          SizedBox(height: 1.5.h),

          // Destaques para amanhã
          _buildNotificationCard(
            icon: Icons.star_outline,
            iconColor: const Color(0xFF1E88E5),
            title: 'Destaques para amanhã',
            subtitle: '',
            value: _tomorrowHighlights,
            onChanged: (value) {
              setState(() => _tomorrowHighlights = value);
            },
          ),

          SizedBox(height: 1.5.h),

          // Próximas horas
          _buildNotificationCard(
            icon: Icons.schedule,
            iconColor: const Color(0xFF1E88E5),
            title: 'Próximas horas',
            subtitle: '',
            value: _nextHours,
            onChanged: (value) {
              setState(() => _nextHours = value);
            },
          ),

          SizedBox(height: 1.5.h),

          // Alertas meteorológicos
          _buildNotificationCard(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Alertas meteorológicos',
            subtitle: '',
            value: _meteorologicalAlerts,
            onChanged: (value) {
              setState(() => _meteorologicalAlerts = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
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
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 2.w),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1E88E5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
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
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Selecionar Localização',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading:
                    Icon(Icons.my_location, color: const Color(0xFF1E88E5)),
                title: Text('Usar localização atual'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedLocation = _selectedLocation;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.search, color: Colors.grey[700]),
                title: Text('Buscar localização'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/city-search');
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}
