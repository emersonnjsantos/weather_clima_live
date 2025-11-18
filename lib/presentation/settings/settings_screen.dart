import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey[800], size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            },
          ),
          title: Text(
            'Configuração',
            style: TextStyle(
              color: const Color(0xFF1E88E5),
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.only(
            top: 2.h,
            bottom: MediaQuery.of(context).padding.bottom + 2.h,
          ),
          children: [
            // Seção: Compartilhar
            _buildSectionTitle('Compartilhar'),
            _buildSettingsCard(
              icon: Icons.share,
              iconColor: const Color(0xFF1E88E5),
              title: 'Compartilhe o APP com seus amigos',
              subtitle: 'Divulgue ClimaLive - Tempo 14 Dias.',
              onTap: () {
                Share.share(
                  'Confira o ClimaLive - Tempo 14 Dias! Um app completo de previsão do tempo com mapas em tempo real e muito mais. Baixe agora!',
                  subject: 'ClimaLive - Previsão do Tempo',
                );
              },
            ),

            SizedBox(height: 2.h),

            // Seção: Personalize seu aplicativo
            _buildSectionTitle('Personalize seu aplicativo'),
            _buildSettingsCard(
              icon: Icons.diamond,
              iconColor: const Color(0xFF00BCD4),
              title: 'Personalização avançada',
              subtitle: 'Escolha quais informações você deseja ver',
              onTap: () {
                // Navegar para personalização avançada
                Navigator.pushNamed(context, '/advanced_customization');
              },
            ),

            SizedBox(height: 2.h),

            // Seção: Notificações
            _buildSectionTitle('Notificações'),
            _buildSettingsCard(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFFF9800),
              title: 'Centro de notificações',
              subtitle: 'Gerencie suas notificações e alertas',
              onTap: () {
                // Navegar para centro de notificações
                Navigator.pushNamed(context, '/notifications-center');
              },
            ),

            SizedBox(height: 2.h),

            // Seção: Âmbito
            _buildSectionTitle('Âmbito'),
            _buildSettingsCard(
              icon: Icons.settings_applications,
              iconColor: const Color(0xFF9C27B0),
              title: 'Configurações avançadas',
              subtitle: 'Prêmios, atualização e permissões',
              onTap: () {
                // Navegar para âmbito
                Navigator.pushNamed(context, '/scope');
              },
            ),

            SizedBox(height: 2.h),

            // Seção: Unidades de medição
            _buildSectionTitle('Unidades de medição'),
            _buildSettingsCard(
              icon: Icons.straighten,
              iconColor: const Color(0xFF4CAF50),
              title: 'Unidades de medição',
              subtitle: 'Temperatura, velocidade, pressão e mais',
              onTap: () {
                // Navegar para unidades de medição
                Navigator.pushNamed(context, '/measurement-units');
              },
            ),

            SizedBox(height: 2.h),

            // Seção: Perfil
            _buildSectionTitle('Perfil'),
            _buildSettingsCard(
              icon: Icons.person_outline,
              iconColor: const Color(0xFFFF5722),
              title: 'Perfil',
              subtitle: 'Aparência, idioma, país e preferências',
              onTap: () {
                // Navegar para perfil
                Navigator.pushNamed(context, '/profile');
              },
            ),

            SizedBox(height: 2.h),

            // Seção: Informação
            _buildSectionTitle('Informação'),
            _buildSettingsCard(
              icon: Icons.help_outline,
              iconColor: const Color(0xFF607D8B),
              title: 'Informação',
              subtitle: 'Privacidade, ajuda, termos e avaliação',
              onTap: () {
                // Navegar para informação
                Navigator.pushNamed(context, '/information');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
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
                        fontSize: 12.sp,
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
}
