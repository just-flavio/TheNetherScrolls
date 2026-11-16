import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const AppIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (color != null) {
      return ImageIcon(
        AssetImage(assetPath),
        size: size,
        color: color,
      );
    }
    
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}