import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayan_digital/models/current_account.dart';
import 'package:sayan_digital/config.dart';

class DetalleDeudaScreen extends StatefulWidget {
  const DetalleDeudaScreen({super.key});

  @override
  State<DetalleDeudaScreen> createState() => _DetalleDeudaScreenState();
}

class _DetalleDeudaScreenState extends State<DetalleDeudaScreen> {
  final bool configPagosHabilitados = AppSwitches.pagosHabilitados;
  final bool configMostrarPagados = AppSwitches.mostrarPagados;

  String? direccionSeleccionada;
  List<int> seleccionadosIds = []; // IDs de deudas marcadas para pagar

  @override
  Widget build(BuildContext context) {
    final tributo =
        ModalRoute.of(context)!.settings.arguments as CurrentAccount;

    // Lógica para Limpieza/Serenazgo: Inicializar la primera dirección si hay varias
    if ((tributo.idConfigTributo == 2 || tributo.idConfigTributo == 3) &&
        direccionSeleccionada == null &&
        tributo.hijos.isNotEmpty) {
      direccionSeleccionada = tributo.hijos.first.direccion;
    }

    // Filtrar deudas según la dirección seleccionada (si aplica)
    List<DeudaHijo> deudasAMostrar = tributo.hijos;
    if (direccionSeleccionada != null) {
      deudasAMostrar = tributo.hijos
          .where((h) => h.direccion == direccionSeleccionada)
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          tributo.descripcion,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00296B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildResumenCabecera(tributo, deudasAMostrar),
          if (direccionSeleccionada != null) _buildSelectorDireccion(tributo),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: deudasAMostrar
                  .map((ano) => _buildYearExpansionTile(ano))
                  .toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomPayBar(),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildResumenCabecera(CurrentAccount tributo, List<DeudaHijo> lista) {
    double deudaTotal = lista.fold(0, (sum, item) => sum + (item.saldo ?? 0));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            "DEUDA TOTAL SELECCIONADA",
            style: GoogleFonts.urbanist(fontSize: 12, color: Colors.grey),
          ),
          Text(
            "S/ ${deudaTotal.toStringAsFixed(2)}",
            style: GoogleFonts.urbanist(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.red[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorDireccion(CurrentAccount tributo) {
    // Extraer direcciones únicas
    final direcciones = tributo.hijos.map((e) => e.direccion).toSet().toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: direccionSeleccionada,
        isExpanded: true,
        underline: const SizedBox(),
        items: direcciones
            .map(
              (dir) => DropdownMenuItem(
                value: dir,
                child: Text(dir ?? "Sin Dirección"),
              ),
            )
            .toList(),
        onChanged: (val) => setState(() => direccionSeleccionada = val),
      ),
    );
  }

  Widget _buildYearExpansionTile(DeudaHijo ano) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15,
        ) /* side: Border.all(color: Colors.grey.shade200) */,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(
          "Año / Periodo: ${ano.periodoC}",
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Saldo: S/ ${ano.saldo?.toStringAsFixed(2)}"),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
              columns: [
                const DataColumn(label: Text("Periodo")),
                const DataColumn(label: Text("Saldo")),
                const DataColumn(label: Text("Estado")),
                if (configPagosHabilitados)
                  const DataColumn(label: Text("Pagar")),
              ],
              rows: ano.detalles
                  .map((det) {
                    if (!configMostrarPagados && det.id == 2)
                      return null; // Ocultar pagados si flag es false

                    return DataRow(
                      cells: [
                        DataCell(Text(det.periodoC)),
                        DataCell(Text("S/ ${det.saldo.toStringAsFixed(2)}")),
                        DataCell(_buildStatusBadge(det.id)),
                        if (configPagosHabilitados)
                          DataCell(
                            (det.id ==
                                    1) // Solo estado 1 (Pendiente) permite checkbox
                                ? Checkbox(
                                    value: seleccionadosIds.contains(det.id),
                                    onChanged: (val) {
                                      setState(() {
                                        val!
                                            ? seleccionadosIds.add(det.id)
                                            : seleccionadosIds.remove(det.id);
                                      });
                                    },
                                  )
                                : const Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                          ),
                      ],
                    );
                  })
                  .whereType<DataRow>()
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int estado) {
    String texto = "Pendiente";
    Color color = Colors.red;
    if (estado == 2) {
      texto = "Pagado";
      color = Colors.green;
    }
    if (estado == 3) {
      texto = "Fracc.";
      color = Colors.blue;
    }
    if (estado == 4) {
      texto = "Coactivo";
      color = Colors.orange[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget? _buildBottomPayBar() {
    if (!configPagosHabilitados || seleccionadosIds.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00296B),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          // Navegar a pasarela de pagos
        },
        child: Text(
          "PROCEDER AL PAGO (${seleccionadosIds.length})",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
