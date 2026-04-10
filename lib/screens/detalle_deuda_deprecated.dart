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
    final cuenta = ModalRoute.of(context)!.settings.arguments as CurrentAccount;

    final isTablet = MediaQuery.of(context).size.width > 600;

    final tributoId = cuenta.idConfigTributo;
    final isMultidireccion = tributoId == 2 || tributoId == 3;

    final currentHijo = cuenta.hijos[_selectedAddressIndex];

    final totales = _calcularTotales(cuenta, isMultidireccion, currentHijo);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(cuenta.descripcion),

          SliverToBoxAdapter(
            child: _buildHeaderResumen(
              totales['total']!,
              totales['pagado']!,
              totales['saldo']!,
              isTablet,
            ),
          ),

          if (isMultidireccion)
            SliverToBoxAdapter(child: _buildAddressSelector(cuenta.hijos)),

          SliverToBoxAdapter(child: _buildLegend()),

          // LISTA
          isMultidireccion
              ? _buildGroupedYearSliver(currentHijo!)
              : _buildGlobalYearSliver(cuenta.hijos),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String title) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      floating: false,
      backgroundColor: const Color(0xFF00296B),

      /* leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ), */

      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00296B), Color(0xFF003F88)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderResumen(
    double total,
    double pagado,
    double saldo,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: 12,
      ),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),

        child: isTablet
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _amountColumn("Total", total, Colors.blueGrey, isTablet),
                  _amountColumn("Pagado", pagado, Colors.green, isTablet),
                  _amountColumn(
                    "Saldo",
                    saldo,
                    Colors.red,
                    isTablet,
                    isHighlight: true,
                  ),
                ],
              )
            : Column(
                children: [
                  _amountColumn("Total", total, Colors.blueGrey, false),
                  const SizedBox(height: 10),
                  _amountColumn("Pagado", pagado, Colors.green, false),
                  const SizedBox(height: 10),
                  _amountColumn(
                    "Saldo",
                    saldo,
                    Colors.red,
                    false,
                    isHighlight: true,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _amountColumn(
    String label,
    double amount,
    Color color,
    bool isTablet, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: isTablet ? 14 : 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "S/ ${amount.toStringAsFixed(2)}",
          style: GoogleFonts.urbanist(
            fontSize: isTablet
                ? (isHighlight ? 22 : 18)
                : (isHighlight ? 18 : 15),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

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

  Widget _buildGroupedYearSliver(DeudaHijo hijo) {
    Map<int, List<DeudaDetalle>> mapAnios = {};

    for (var det in hijo.detalles) {
      final anio = det.ano ?? 0;
      mapAnios.putIfAbsent(anio, () => []).add(det);
    }

    final sortedYears = mapAnios.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final anio = sortedYears[index];
        final detalles = mapAnios[anio]!;

        return _buildYearCard(anio, detalles);
      }, childCount: sortedYears.length),
    );
  }

  Widget _buildYearCard(int anio, List<DeudaDetalle> detalles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ExpansionTile(
          title: Text("AÑO $anio"),
          children: [_buildResponsiveTable(detalles)],
        ),
      ),
    );
  }

  Widget _buildResponsiveTable(List<DeudaDetalle> detalles) {
    final isSmall = MediaQuery.of(context).size.width < 400;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: isSmall ? 700 : MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('PERIODO')),
            DataColumn(label: Text('ESTADO')),
            DataColumn(label: Text('INSOLUTO')),
            DataColumn(label: Text('INTERÉS')),
            DataColumn(label: Text('SALDO')),
          ],
          rows: detalles.map((d) {
            return DataRow(
              cells: [
                DataCell(Text(d.periodoC ?? "-")),
                DataCell(_buildStatusBadge(d.estado ?? 0)),
                DataCell(Text("${d.valorDeuda ?? 0}")),
                DataCell(Text("${d.valorInteres ?? 0}")),
                DataCell(Text("${d.saldo ?? 0}")),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGlobalYearSliver(List<DeudaHijo> hijos) {
  Map<int, List<DeudaHijo>> mapAnios = {};

  for (var h in hijos) {
    final anio = h.ano ?? 0;
    if (anio != 0) {
      mapAnios.putIfAbsent(anio, () => []).add(h);
    }
  }

  final sortedYears = mapAnios.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  if (sortedYears.isEmpty) {
    return const SliverToBoxAdapter(
      child: Center(child: Text("No hay periodos registrados")),
    );
  }

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final anio = sortedYears[index];
        final lista = mapAnios[anio]!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ExpansionTile(
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
                    columns: const [
                      DataColumn(label: Text('PERIODO')),
                      DataColumn(label: Text('ESTADO')),
                      DataColumn(label: Text('INSOLUTO')),
                      DataColumn(label: Text('INTERÉS')),
                      DataColumn(label: Text('SALDO')),
                    ],
                    rows: lista.map((h) {
                      double saldo =
                          (h.estado == 3) ? 0 : (h.saldo ?? 0);

                      return DataRow(cells: [
                        DataCell(Text(h.periodoC ?? "-")),
                        DataCell(_buildStatusBadge(h.estado ?? 0)),
                        DataCell(Text("S/ ${(h.valorDeuda ?? 0).toStringAsFixed(2)}")),
                        DataCell(Text("S/ ${(h.valorInteres ?? 0).toStringAsFixed(2)}")),
                        DataCell(
                          Text(
                            "S/ ${saldo.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: saldo > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
      childCount: sortedYears.length,
    ),
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

  Map<String, double> _calcularTotales(
    CurrentAccount cuenta,
    bool isMultidireccion,
    DeudaHijo currentHijo,
  ) {
    double totalDeuda = 0;
    double totalPagado = 0;
    double totalSaldo = 0;

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
      for (var h in cuenta.hijos) {
        totalDeuda +=
            (h.valorDeuda ?? 0) +
            (h.valorDerechoEmision ?? 0) +
            (h.valorInteres ?? 0);

        totalPagado += (h.pago ?? 0);
        totalSaldo += (h.estado == 3) ? 0 : (h.saldo ?? 0);
      }
    }

    return {"total": totalDeuda, "pagado": totalPagado, "saldo": totalSaldo};
  }
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
