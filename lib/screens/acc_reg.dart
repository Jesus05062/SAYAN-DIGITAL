import 'package:flutter/material.dart';
import 'package:sayan_digital/widgets/custom_background.dart';

class AppRoutes {
  static const login = 'acceder';
  static const register = 'registro';
}

class AccReg extends StatelessWidget {
  const AccReg({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Muni
                Image.asset(
                  "images/logo_municipio.png",
                  height: size.height * 0.25,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: size.height * 0.40),

                // Botón Acceder
                _buildPrimaryButton(
                  label: "Acceder",
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.login),
                ),

                const SizedBox(height: 20),

                // Botón Registrarse
                _buildSecondaryButton(
                  label: "Regístrese",
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Botón principal (sólido)
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F), // Azul corporativo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Botón secundario (bordeado, transparente)
  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1E3A5F), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Color(0xFF1E3A5F),
          ),
        ),
      ),
    );
  }
}
