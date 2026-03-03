import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child; // contenido que irá encima del fondo

  const CustomBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/municipio_oficial.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradiente superpuesto
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.6),
                Colors.white.withValues(alpha: 0.3),
                Colors.white,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),

        // Contenido principal
        child,
      ],
    );
  }
}
