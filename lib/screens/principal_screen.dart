import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayan_digital/models/current_account.dart';
import 'package:sayan_digital/providers/current_account_provider.dart';
import 'package:sayan_digital/providers/auth_provider.dart';
import 'package:sayan_digital/widgets/menu.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    /* final Map<String, dynamic> argumentos = (args is Map<String, dynamic>)
        ? args
        : {"codigo": "000000", "direccion": "Sin dirección"}; */

    // Extraemos los valores (con un respaldo por si las llaves vienen nulas)
    final String contribCodigo = args['codigo'] ?? "000000";
    final String nombreCompleto = args['nombreCompleto'] ?? "Sin nombre";

    final accountProvider = Provider.of<CurrentAccountProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final cuentas = accountProvider.cuentas;

    //total general sumando el campo 'porPagar' de cada tributo
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

  /* Widget _buildTributosList(List<CurrentAccount> cuentas) {
    if (cuentas.isEmpty) {
      return const Center(child: Text("No se encontraron deudas pendientes."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cuentas.length,
      itemBuilder: (context, index) {
        final tributo = cuentas[index];

        return GestureDetector(
          onTap: () =>
              _showDesgloseModal(context, tributo), // <--- Llamada al modal
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white),
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
                          color: const Color(0xFF00296B),
                        ),
                      ),
                      Text(
                        "Deuda total: S/ ${tributo.total.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        );
      },
    );
  } */

  /* Widget _buildTributosList(List<CurrentAccount> cuentas) {
    // Usamos el modelo exacto
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
          margin: const EdgeInsets.only(bottom: 18), // Un poco más de espacio
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // Esquinas más suaves
            // EFECTO DE RESALTADO (Sombreado)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Sombra muy sutil
                blurRadius: 10,
                offset: const Offset(0, 4), // Sombra hacia abajo
              ),
            ],
            border: Border.all(
              color: Colors.white,
            ), // Borde blanco para "limpiar" la tarjeta
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
                        color: const Color(
                          0xFF00296B,
                        ), // Usamos el azul institucional
                      ),
                    ),
                    Text(
                      "Interés acumulado: S/ ${tributo.interes.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // ... resto del código (Montos)
            ],
          ),
        );
      },
    );
  } */

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

  /* void _showDesgloseModal(BuildContext context, CurrentAccount tributo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Para bordes redondeados personalizados
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.7, // 70% de la pantalla
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Barra superior del modal
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Desglose: ${tributo.descripcion}",
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00296B),
                  ),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tributo.hijos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final hijo =
                        tributo.hijos[index]; // Acceso al modelo DeudaHijo

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Periodo: ${hijo.periodoC ?? 'N/A'}",
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: hijo.direccion != null
                          ? Text(
                              hijo.direccion!,
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                      trailing: Text(
                        "S/ ${hijo.saldo?.toStringAsFixed(2) ?? '0.00'}",
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red[700],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Botón de cierre
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00296B),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "CERRAR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  } */

  /* void _showDesgloseModal(BuildContext context, CurrentAccount tributo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Para bordes redondeados personalizados
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.7, // 70% de la pantalla
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Barra superior del modal
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Desglose: ${tributo.descripcion}",
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00296B),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tributo.hijos.length,
                  itemBuilder: (context, index) {
                    final hijo = tributo.hijos[index]; // Modelo DeudaHijo

                    return Theme(
                      // Quitamos las líneas divisorias que ExpansionTile pone por defecto
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00296B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: Color(0xFF00296B),
                          ),
                        ),
                        title: Text(
                          "Periodo: ${hijo.periodoC ?? 'N/A'}",
                          style: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Saldo: S/ ${hijo.saldo?.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        // AQUÍ SE MUESTRAN LOS DETALLES (DeudaDetalle)
                        children: hijo.detalles.map((detalle) {
                          return Container(
                            margin: const EdgeInsets.only(left: 45, bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Concepto ID: ${detalle.id}", // O el nombre si lo tuvieras
                                      style: GoogleFonts.urbanist(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "Deuda base: S/ ${detalle.valorDeuda.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "S/ ${detalle.saldo.toStringAsFixed(2)}",
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00296B),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              // Botón de cierre
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00296B),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "CERRAR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 */
}
