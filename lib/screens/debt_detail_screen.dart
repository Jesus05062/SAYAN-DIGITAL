import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayan_digital/models/current_account.dart';

class DetalleDeudaScreen extends StatefulWidget {
  const DetalleDeudaScreen({super.key});

  @override
  State<DetalleDeudaScreen> createState() => _DetalleDeudaScreenState();
}

class _DetalleDeudaScreenState extends State<DetalleDeudaScreen> {
  int _selectedAddressIndex = 0;

  @override
  Widget build(BuildContext context) {
    // EXTRAEMOS EL OBJETO ENVIADO DESDE PRINCIPAL_SCREEN
    final cuenta = ModalRoute.of(context)!.settings.arguments as CurrentAccount;

    final isTablet = MediaQuery.of(context).size.width > 600;

    final tributoId = cuenta.idConfigTributo;
    final isMultidireccion = tributoId == 2 || tributoId == 3;

    // Obtenemos el grupo de deudas actual (por dirección o global)
    final DeudaHijo currentHijo = cuenta.hijos[_selectedAddressIndex];

    // CÁLCULOS DINÁMICOS PARA EL HEADER
    double totalDeuda = 0;
    double totalPagado = 0;
    double totalSaldo = 0;

    // Si es multidirección, calculamos solo lo del predio seleccionado,
    // si no (Predial/Fracc), calculamos el total de la cuenta.
    if (isMultidireccion) {
      for (var det in currentHijo.detalles) {
        totalDeuda +=
            (det.valorDeuda ?? 0) +
            (det.valorDerechoEmision ?? 0) +
            (det.valorInteres ?? 0);
        totalPagado += (det.pago ?? 0);
        totalSaldo += (det.estado == 3) ? 0 : (det.saldo ?? 0);
      }
    } else {
      for (var det in cuenta.hijos) {
        totalDeuda +=
            (det.valorDeuda ?? 0) +
            (det.valorDerechoEmision ?? 0) +
            (det.valorInteres ?? 0);
        totalPagado += (det.pago ?? 0);
        totalSaldo += (det.estado == 3) ? 0 : (det.saldo ?? 0);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00296B),
        title: Text(
          cuenta.descripcion,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildHeaderResumen(totalDeuda, totalPagado, totalSaldo),
          if (isMultidireccion) _buildAddressSelector(cuenta.hijos),
          _buildLegend(),
          Expanded(
            child: isMultidireccion
                ? _buildGroupedYearList(currentHijo)
                : _buildGlobalYearList(cuenta.hijos),
          ),
        ],
      ),
    );
  }



  Widget _buildHeaderResumen(double total, double pagado, double saldo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00296B).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _amountColumn("Monto Total", total, Colors.blueGrey),
          _amountColumn("Pagado", pagado, Colors.green),
          _amountColumn("POR PAGAR", saldo, Colors.red, isHighlight: true),
        ],
      ),
    );
  }

  Widget _amountColumn(
    String label,
    double amount,
    Color color, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "S/ ${amount.toStringAsFixed(2)}",
          style: GoogleFonts.urbanist(
            fontSize: isHighlight ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /* Widget _buildAddressSelector(List<DeudaHijo> hijos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Seleccione el predio:",
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        Container(
          height: 60,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: hijos.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedAddressIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(hijos[index].direccion ?? 'Predio ${index + 1}'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF00296B).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF00296B) : Colors.grey,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (val) =>
                      setState(() => _selectedAddressIndex = index),
                ),
              );
            },
          ),
        ),
      ],
    );
  } */

  Widget _buildAddressSelector(List<DeudaHijo> hijos) {
  final selected = hijos[_selectedAddressIndex];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Seleccione el predio:",
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => _openAddressSelectorModal(hijos),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected.direccion ?? 'Seleccionar predio',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  void _openAddressSelectorModal(List<DeudaHijo> hijos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _AddressSearchModal(
          hijos: hijos,
          onSelected: (index) {
            setState(() {
              _selectedAddressIndex = index;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildGroupedYearList(DeudaHijo hijo) {
    Map<int, List<DeudaDetalle>> mapAnios = {};
    for (var det in hijo.detalles) {
      final anio = det.ano ?? 0;
      mapAnios.putIfAbsent(anio, () => []).add(det);
    }
    final sortedYears = mapAnios.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final anio = sortedYears[index];
        final detalles = mapAnios[anio]!;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          // CORRECCIÓN AQUÍ: Usamos 'side' en lugar de 'border'
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              title: Text(
                "AÑO $anio",
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00296B),
                ),
              ),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                    columns: const [
                      DataColumn(label: Text('PERIODO')),
                      DataColumn(label: Text('ESTADO')),
                      DataColumn(label: Text('INSOLUTO')),
                      DataColumn(label: Text('D. EMISION')),
                      DataColumn(label: Text('INTERÉS')),
                      DataColumn(label: Text('PAGOS')),
                      DataColumn(label: Text('SALDO')),
                    ],
                    rows: detalles
                        .map(
                          (d) => DataRow(
                            cells: [
                              DataCell(Text(d.periodoC ?? "-")),
                              DataCell(_buildStatusBadge(d.estado ?? 0)),
                              DataCell(
                                Text(
                                  "S/ ${(d.valorDeuda ?? 0).toStringAsFixed(2)}",
                                ),
                              ),
                              DataCell(
                                Text(
                                  "S/ ${(d.valorDerechoEmision ?? 0).toStringAsFixed(2)}",
                                ),
                              ),
                              DataCell(
                                Text(
                                  "S/ ${(d.valorInteres ?? 0).toStringAsFixed(2)}",
                                ),
                              ),
                              DataCell(
                                Text("S/ ${(d.pago ?? 0).toStringAsFixed(2)}"),
                              ),
                              DataCell(
                                Text(
                                  (d.estado == 3)
                                      ? "0.00"
                                      : "S/ ${(d.saldo ?? 0).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (d.saldo ?? 0) > 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlobalYearList(List<DeudaHijo> todosLosHijos) {
    // 1. Agrupamos todos los periodos de todos los hijos por Año
    Map<int, List<DeudaHijo>> mapAnios = {};

    for (var hijo in todosLosHijos) {
      final anio = hijo.ano ?? 0;
      if (anio != 0) {
        mapAnios.putIfAbsent(anio, () => []).add(hijo);
      }
    }

    // 2. Ordenamos los años de mayor a menor
    final sortedYears = mapAnios.keys.toList()..sort((a, b) => b.compareTo(a));

    if (sortedYears.isEmpty) {
      return const Center(child: Text("No hay periodos registrados"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final anio = sortedYears[index];
        final periodosDelAnio = mapAnios[anio]!;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded:
                  index == 0, // Expande el año más reciente por defecto
              title: Text(
                "AÑO $anio",
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00296B),
                ),
              ),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                    columns: const [
                      DataColumn(label: Text('PERIODO')),
                      DataColumn(label: Text('ESTADO')),
                      DataColumn(label: Text('INSOLUTO')),
                      DataColumn(label: Text('D. EMISION')),
                      DataColumn(label: Text('INTERÉS')),
                      DataColumn(label: Text('PAGOS')),
                      DataColumn(label: Text('SALDO')),
                    ],
                    rows: periodosDelAnio.map((h) {
                      // Calculamos el saldo real para la fila
                      double saldoFila = (h.estado == 3) ? 0 : (h.saldo ?? 0);

                      return DataRow(
                        cells: [
                          DataCell(Text(h.periodoC ?? "-")),
                          DataCell(_buildStatusBadge(h.estado ?? 0)),
                          DataCell(
                            Text(
                              "S/ ${(h.valorDeuda ?? 0).toStringAsFixed(2)}",
                            ),
                          ),
                          DataCell(
                            Text(
                              "S/ ${(h.valorDerechoEmision ?? 0).toStringAsFixed(2)}",
                            ),
                          ),
                          DataCell(
                            Text(
                              "S/ ${(h.valorInteres ?? 0).toStringAsFixed(2)}",
                            ),
                          ),
                          DataCell(
                            Text("S/ ${(h.pago ?? 0).toStringAsFixed(2)}"),
                          ),
                          DataCell(
                            Text(
                              "S/ ${saldoFila.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: saldoFila > 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(int estado) {
    Color color;
    String text;
    switch (estado) {
      case 1:
        color = Colors.orange;
        text = "PENDIENTE";
        break;
      case 2:
        color = Colors.green;
        text = "PAGADO";
        break;
      case 3:
        color = Colors.pinkAccent;
        text = "FRACCION";
        break;
      case 4:
        color = Colors.red;
        text = "COACTIVO";
        break;
      default:
        color = Colors.grey;
        text = "N/A";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Wrap(
        spacing: 15,
        children: [
          _legItem(Colors.orange, "Pendiente"),
          _legItem(Colors.green, "Pagado"),
          _legItem(Colors.pinkAccent, "Fraccionado"),
          _legItem(Colors.red, "Coactivo"),
        ],
      ),
    );
  }

  Widget _legItem(Color c, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(t, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

class _AddressSearchModal extends StatefulWidget {
  final List<DeudaHijo> hijos;
  final Function(int) onSelected;

  const _AddressSearchModal({required this.hijos, required this.onSelected});

  @override
  State<_AddressSearchModal> createState() => _AddressSearchModalState();
}

class _AddressSearchModalState extends State<_AddressSearchModal> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.hijos.asMap().entries.where((entry) {
      final direccion = (entry.value.direccion ?? "").toLowerCase();

      final words = query.toLowerCase().split(" ");

      return words.every((word) => direccion.contains(word));
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔍 BUSCADOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar dirección...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // 📋 LISTA FILTRADA
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final entry = filtered[index];
                  final realIndex = entry.key;
                  final hijo = entry.value;

                  return ListTile(
                    title: Text(
                      hijo.direccion ?? "Sin dirección",
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () => widget.onSelected(realIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


