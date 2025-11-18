import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar o SVG
  final svgString = await File('assets/images/logo.svg').readAsString();
  final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

  // Criar uma imagem PNG
  final image = await pictureInfo.picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Salvar como PNG
  await File('assets/images/logo.png').writeAsBytes(buffer);

  print('✅ Ícone PNG gerado com sucesso: assets/images/logo.png');
  exit(0);
}
