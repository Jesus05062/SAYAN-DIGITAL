import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sayan_digital/providers/auth_provider.dart';

class MyMenu extends StatelessWidget {
  const MyMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final datosLength = authProvider.user?.detalle.length;

    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.7, // Responsive: 70% del ancho
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Encabezado con logo
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 168, 220, 247),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                                    'images/logo_municipio.png',
                                    fit: BoxFit.contain,
                                    width: screenWidth * 0.4,
                                  ),
                ),
              ),
            ),

            // Opcion dinámica
            if (datosLength! > 1)
              _MenuItem(
                label: "Codigos",
                icon: Icons.home,
                onTap: () {
                  Navigator.pushReplacementNamed(context, 'codigos');
                },
              ),

            _MenuItem(
              label: "Cambiar Contraseña",
              icon: Icons.lock_reset,
              onTap: () {
                Navigator.pushReplacementNamed(context, 'validar_dni');
              },
            ),

            /* _MenuItem(
              label: "Contacto",
              icon: Icons.contact_mail,
              onTap: () => _showContactoPopup(context)
            ), */

            const Divider(height: 30, color: Colors.black,),

            // Cerrar sesión al final
            _MenuItem(
              label: "Cerrar Sesión",
              icon: Icons.exit_to_app,
              color: Colors.red.shade700,
              onTap: () {
                Navigator.pushReplacementNamed(context, 'inicio');
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showContactoPopup(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Información de Contacto",
            style: GoogleFonts.urbanist(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          content: SizedBox(
            width: screenWidth * 0.7, // Popup responsivo
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📞 Teléfono: +51 987 654 321",
                    style: GoogleFonts.urbanist(fontSize: 16)),
                const SizedBox(height: 10),
                Text("💬 Teléfono: +51 987 654 321",
                    style: GoogleFonts.urbanist(fontSize: 16)),
                const Divider(height: 30, color: Colors.black),
                Text("📧 Email: helpdesk@munisayan.gob.pe",
                    style: GoogleFonts.urbanist(fontSize: 16)),
                const Divider(height: 30, color: Colors.black,),
                Text("📍 Dirección: Av. Siempre Viva 123, Lima",
                    style: GoogleFonts.urbanist(fontSize: 16)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cerrar",
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }
}


class _MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 28, color: color ?? Colors.blueGrey.shade800),
      title: Text(
        label,
        style: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.blueGrey.shade900,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}


