import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayan_digital/providers/current_account_provider.dart';
import 'package:sayan_digital/providers/auth_provider.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos de los providers
    final accountProvider = Provider.of<CurrentAccountProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final cuentas = accountProvider.cuentas;

    // Calculamos el total general sumando el campo 'porPagar' de cada tributo
    final double totalDeuda = cuentas.fold(
      0,
      (sum, item) => sum + item.porPagar,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(
        context,
        user?.detalle[0].nombreCompleto ?? "Usuario",
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            accountProvider.getDeudas(user?.detalle[0].contrib ?? ""),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(user?.detalle[0].contrib ?? ""),
              const SizedBox(height: 25),
              _buildTotalCard(totalDeuda),
              const SizedBox(height: 30),
              Text(
                "Desglose por Tributos",
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00296B),
                ),
              ),
              const SizedBox(height: 15),
              _buildTributosList(cuentas),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String nombre) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF00296B),
      title: Text(
        "Sayan Digital",
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(String codigo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Estado de Cuenta",
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          "Código: $codigo",
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00296B), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00296B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "TOTAL A PAGAR",
            style: GoogleFonts.urbanist(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "S/ ${total.toStringAsFixed(2)}",
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF00296B),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "PAGAR AHORA",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTributosList(List cuentas) {
    if (cuentas.isEmpty) {
      return const Center(child: Text("No se encontraron deudas pendientes."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cuentas.length,
      itemBuilder: (context, index) {
        final tributo = cuentas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _buildIconForTributo(tributo.descripcion),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tributo.descripcion,
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Insoluto: S/ ${tributo.insoluto.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "S/ ${tributo.porPagar.toStringAsFixed(2)}",
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: tributo.porPagar > 0
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconForTributo(String desc) {
    IconData iconData = Icons.receipt_long_rounded;
    Color color = Colors.blue;

    if (desc.contains("PREDIAL")) {
      iconData = Icons.home_rounded;
      color = Colors.orange;
    } else if (desc.contains("LIMPIEZA")) {
      iconData = Icons.delete_outline_rounded;
      color = Colors.green;
    } else if (desc.contains("SERENAZGO")) {
      iconData = Icons.security_rounded;
      color = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color),
    );
  }
}
