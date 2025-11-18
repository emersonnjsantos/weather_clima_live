import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ScopeScreen extends StatefulWidget {
  const ScopeScreen({super.key});

  @override
  State<ScopeScreen> createState() => _ScopeScreenState();
}

class _ScopeScreenState extends State<ScopeScreen> {
  int _refreshInterval = 1; // 1 hora por padrão

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
          'Âmbito',
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
          // Prêmios
          _buildScopeCard(
            icon: Icons.emoji_events,
            iconColor: const Color(0xFF1E88E5),
            title: 'Prêmios',
            subtitle: 'Seja um especialista',
            onTap: () {
              // Navegar para tela de prêmios
              _showComingSoonDialog('Prêmios');
            },
          ),

          SizedBox(height: 1.5.h),

          // Refrescar dados
          _buildRefreshCard(
            icon: Icons.access_time,
            iconColor: const Color(0xFF1E88E5),
            title: 'Refrescar dados cada:',
            subtitle:
                '$_refreshInterval hora${_refreshInterval > 1 ? 's' : ''}',
            onTap: () {
              _showRefreshIntervalDialog();
            },
          ),

          SizedBox(height: 1.5.h),

          // Problemas de atualização
          _buildScopeCard(
            icon: Icons.info_outline,
            iconColor: const Color(0xFFFF9800),
            title: 'Problemas de atualização?',
            subtitle: '',
            onTap: () {
              // Mostrar ajuda sobre problemas de atualização
              _showUpdateProblemsHelp();
            },
          ),

          SizedBox(height: 1.5.h),

          // Permissão de localização
          _buildScopeCard(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Permissão de localização',
            subtitle: 'Garantido',
            subtitleColor: Colors.grey[600],
            onTap: () {
              // Mostrar status de permissão
              _showLocationPermissionStatus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScopeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
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
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subtitleColor ?? Colors.grey[600],
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshCard({
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
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
                      subtitle,
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

  void _showRefreshIntervalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Intervalo de Atualização',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIntervalOption('30 minutos', 0.5),
              _buildIntervalOption('1 hora', 1),
              _buildIntervalOption('2 horas', 2),
              _buildIntervalOption('3 horas', 3),
              _buildIntervalOption('6 horas', 6),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntervalOption(String label, double hours) {
    final isSelected = _refreshInterval == hours;
    return RadioListTile<double>(
      title: Text(label),
      value: hours,
      groupValue: _refreshInterval.toDouble(),
      activeColor: const Color(0xFF1E88E5),
      selected: isSelected,
      onChanged: (value) {
        setState(() {
          _refreshInterval = value!.toInt();
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervalo definido para $label'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showUpdateProblemsHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline,
                  color: const Color(0xFFFF9800), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Problemas de Atualização',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Se você está tendo problemas com a atualização dos dados:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildHelpItem('1. Verifique sua conexão com a internet'),
                _buildHelpItem('2. Certifique-se de que o GPS está ativado'),
                _buildHelpItem('3. Tente ajustar o intervalo de atualização'),
                _buildHelpItem('4. Limpe o cache do aplicativo'),
                _buildHelpItem('5. Reinicie o aplicativo'),
                SizedBox(height: 2.h),
                Text(
                  'Se o problema persistir, entre em contato com o suporte.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h, left: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: const Color(0xFF1E88E5),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionStatus() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shield, color: const Color(0xFF4CAF50), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Permissão de Localização',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Garantido',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'O aplicativo tem permissão para acessar sua localização.',
                style: TextStyle(fontSize: 13.sp),
              ),
              SizedBox(height: 1.h),
              Text(
                'Isso permite que você receba previsões do tempo precisas para sua região.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.emoji_events,
                  color: const Color(0xFFFFD700), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: Text(
            'Esta funcionalidade estará disponível em breve!\n\nFique ligado para novidades.',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
