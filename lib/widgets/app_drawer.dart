import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'gps_location_widget.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _createHeader(),
                  _createDrawerItem(
                    icon: Icons.home_outlined,
                    text: 'ClimaLive',
                    onTap: () {},
                  ),
                  _createDrawerItem(
                    icon: Icons.cloud_outlined,
                    text: 'Previsão',
                    onTap: () {},
                    trailing: Icon(Icons.expand_less),
                  ),
                  // Widget GPS separado
                  const GpsLocationWidget(),
                  _createDrawerItem(
                    icon: Icons.search,
                    text: 'Meus locais',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/favorite-cities');
                    },
                  ),
                  _createDrawerItem(
                    icon: Icons.calendar_today_outlined,
                    text: 'Notícias',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/news-screen');
                    },
                  ),
                  _createDrawerItem(
                    icon: Icons.play_circle_outline,
                    text: 'Videos',
                    onTap: () {},
                  ),
                  _createDrawerItem(
                    icon: Icons.warning_amber_outlined,
                    text: 'Alertas',
                    onTap: () {},
                  ),
                  _createDrawerItem(
                    icon: Icons.radar_outlined,
                    text: 'Radar de Chuva',
                    onTap: () {},
                  ),
                  _createDrawerItem(
                    icon: Icons.map_outlined,
                    text: 'Mapas',
                    onTap: () {},
                  ),
                  _createDrawerItem(
                    icon: Icons.satellite_alt_outlined,
                    text: 'Satélites',
                    onTap: () {},
                  ),
                  _createDrawerItem(
                    icon: Icons.support_agent_outlined,
                    text: 'Assistente ClimaLive',
                    onTap: () {},
                  ),
                  _createDrawerItem(
                    icon: Icons.settings_outlined,
                    text: 'Configuração',
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
            // Item Premium fixo na parte inferior com espaçamento
            SafeArea(
              top: false,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.pushNamed(context, '/premium');
                  });
                },
                child: Container(
                  color: Colors.lightBlue[50],
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/diamond.svg',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Assinatura Premium',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createHeader() {
    return Container(
      height: 10.h,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(
              HugeIcons.strokeRoundedThermometerCold,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(width: 3.w),
            Text(
              'ClimaLive',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    GestureTapCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () async {
                await Future.delayed(const Duration(milliseconds: 150));
                onTap();
              }
            : null,
        splashColor: Colors.grey.withOpacity(0.4),
        highlightColor: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
          title: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
          ),
          trailing: trailing,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
