import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayan_digital/models/current_account.dart';
import 'package:sayan_digital/providers/current_account_provider.dart';
import 'package:sayan_digital/providers/auth_provider.dart';
import 'package:sayan_digital/widgets/menu.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  double _calcularSaldoReal(dynamic entrada) {
      double totalCuentas = 0;

      List<CurrentAccount> listaCuentas = [];

      if (entrada is CurrentAccount) {
        listaCuentas = [entrada];
      } else if (entrada is List<CurrentAccount>) {
        listaCuentas = entrada;
      }

      for (var cuenta in listaCuentas) {
        final tributoId = cuenta.idConfigTributo;
        final isMultidireccion = tributoId == 2 || tributoId == 3;

        if (isMultidireccion) {
          for (var hijo in cuenta.hijos) {
            if (hijo.detalles != null) {
              for (var det in hijo.detalles!) {
                totalCuentas += (det.estado == 3) ? 0 : (det.saldo ?? 0);
              }
            }
          }
        } else {
          for (var hijo in cuenta.hijos) {
            totalCuentas += (hijo.estado == 3) ? 0 : (hijo.saldo ?? 0);
          }
        }
      }

      return totalCuentas;
    }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Extraemos los valores (con un respaldo por si las llaves vienen nulas)
    final String contribCodigo = args['codigo'] ?? "000000";
    final String nombreCompleto = args['nombreCompleto'] ?? "Sin nombre";

    final accountProvider = Provider.of<CurrentAccountProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final cuentas = accountProvider.cuentas;

    //total general sumando el campo 'porPagar' de cada tributo
    final double totalDeuda = _calcularSaldoReal(cuentas);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(
        context,
        user?.detalle[0].nombreCompleto ?? "Usuario",
      ),
      drawer: MyMenu(),
      body: RefreshIndicator(
        onRefresh: () => accountProvider.getDeudas(contribCodigo),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(contribCodigo, nombreCompleto),
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

      iconTheme: const IconThemeData(color: Colors.white),

      title: Text(
        "Estado de cuenta",
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

  Widget _buildWelcomeSection(String codigo, String nombreCompleto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Código: $codigo",
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        Text(
          nombreCompleto,
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 13, 63, 201),
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
            color: const Color(0xFF00296B).withValues(alpha: 0.3),
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
          /* ElevatedButton(
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
          ), */
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
        return InkWell(
          onTap: () =>
              Navigator.pushNamed(context, 'detalle_deuda', arguments: tributo),
          child: Container(
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
                    _buildTotalTributo(tributo),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalTributo(CurrentAccount deuda) {
    final tributoId = deuda.idConfigTributo;
    final isMultidireccion = tributoId == 2 || tributoId == 3;
    double total = 0;

    final List currentHijo = deuda.hijos;

    if (isMultidireccion) {
      for (var hijo in currentHijo) {
        for (var det in hijo.detalles) {
          total += (det.estado == 3) ? 0 : (det.saldo ?? 0);
        }
      }
    } else {
      for (var det in currentHijo) {
        total += (det.estado == 3) ? 0 : (det.saldo ?? 0);
      }
    }

    return Text(
      "S/ ${total.toStringAsFixed(2)}",
      style: GoogleFonts.urbanist(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: total > 0 ? Colors.red.shade700 : Colors.green.shade700,
      ),
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
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color),
    );
  }
}
