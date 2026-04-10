/* import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sayan_digital/screens/menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _PrincipalState();
}

class _PrincipalState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isExpanded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarOpciones(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // <-- IMPORTANTE para evitar memory leaks
    super.dispose();
  }

  void _toggleProfile() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contrib = Provider.of<IngresarProvider>(context);
    final predioProvider = Provider.of<PredioProvider>(context);
    final String codigo = contrib.contribProvider;
    final String Token = contrib.token;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyMenu(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menú hamburguesa
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
            const TitleSection(),
            const SizedBox(height: 20),
            // Opciones
            Expanded(
              child: Consumer<PredioProvider>(
                builder: (context, provider, _) {
                  final contrib = Provider.of<IngresarProvider>(context);
                  final lista = contrib.listaPrincipal;
                  if (lista.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay deudas disponibles",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final opcion = lista[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _OptionCard(
                          title: opcion['tipo'],
                          imagePath: opcion['img'],
                          onTap: () async {
                            final ruta = opcion['ruta']?.toString() ?? '';
                            final predioProvider = Provider.of<PredioProvider>(
                              context,
                              listen: false,
                            );
                            final ingresarProvider =
                                Provider.of<IngresarProvider>(
                                  context,
                                  listen: false,
                                );
                            final fraccionad =
                                Provider.of<FraccionamientoProvider>(
                                  context,
                                  listen: false,
                                );

                            _showLoading(
                              context,
                              "Cargando ${opcion['tipo']}...",
                            );

                            try {
                              if (ruta == 'predios') {
                                // Cargar predios
                                final ok = await predioProvider.getPredios(
                                  ingresarProvider.contribProvider,
                                  ingresarProvider.token,
                                );
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                print('************************');
                                print(ok);
                                print('************************');
                                if (!ok ||
                                    predioProvider.predioGlobal.isEmpty) {
                                  mostrarAlertaTokenExpirado(context);
                                  return;
                                }
                              } else if (ruta == 'select_arbitrios') {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              } else if (ruta == 'fraccionado') {
                                final ok = await fraccionad.getPredios(
                                  ingresarProvider.contribProvider,
                                  ingresarProvider.token,
                                );
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();

                                if (!ok || fraccionad.predioGlobal.isEmpty) {
                                  mostrarAlertaTokenExpirado(context);
                                  return;
                                }
                              }

                              if (ruta.isNotEmpty) {
                                Navigator.pushReplacementNamed(context, ruta);
                              } else {
                                displayCustomAlert(
                                  context: context,
                                  icon: Icons.warning_amber,
                                  message: "Ruta no definida para esta opción.",
                                  color: Colors.orangeAccent,
                                );
                              }
                            } catch (e) {
                              Navigator.of(context, rootNavigator: true).pop();
                              displayCustomAlert(
                                context: context,
                                icon: Icons.error_outline,
                                message: "Error al cargar la opción: $e",
                                color: Colors.redAccent,
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showLoading(context, "Cargando perfil...");

          final isValidToken = await predioProvider.getDatos(codigo, Token);

          Navigator.of(context, rootNavigator: true).pop();

          if (!isValidToken) {
            mostrarAlertaTokenExpirado(context);
            return;
          }

          _toggleProfile();
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(
          Icons.person_2_outlined,
          size: 28,
          color: Colors.white,
        ),
      ),

      bottomSheet: SizeTransition(
        sizeFactor: _animation,
        axisAlignment: -1.0,
        child: _isExpanded
            ? _buildBottomSheet(predioProvider.datos)
            : const SizedBox(),
      ),
    );
  }

  Widget _buildBottomSheet(List<dynamic> datos) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: datos.length,
        itemBuilder: (context, index) {
          final data = datos[index];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Perfil",
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                ),
                const Divider(height: 30, thickness: 1),
                _ProfileItem(
                  label: "Código de Contribuyente",
                  value: data['contrib'],
                ),
                _ProfileItem(
                  label: "Apellidos y Nombres / Razón Social",
                  value:
                      "${data['ap_paterno'].trim()} ${data['ap_materno'].trim()} ${data['nombres'].trim()}",
                ),
                _ProfileItem(
                  label: "Domicilio Fiscal",
                  value: data['direcc'].trim(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cargarOpciones(BuildContext context) async {
    final contrib = Provider.of<IngresarProvider>(context, listen: false);
    final predioProvider = Provider.of<PredioProvider>(context, listen: false);
    _showLoading(context, "Cargando menú...");

    final ok = await contrib.PrincipalMenu(
      contrib.contribProvider,
      contrib.token,
    );
    Navigator.of(context, rootNavigator: true).pop();
    if (!ok) {
      mostrarAlertaTokenExpirado(context);
    }
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¡Bienvenido!",
            style: GoogleFonts.urbanist(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "¿Qué consulta deseas realizar?",
            style: GoogleFonts.urbanist(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
 */
