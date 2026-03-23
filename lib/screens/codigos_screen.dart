import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sayan_digital/providers/auth_provider.dart';
import 'package:sayan_digital/providers/current_account_provider.dart'; 

class CodigosScreen extends StatefulWidget {
  const CodigosScreen({super.key});

  @override
  State<CodigosScreen> createState() => _CodigosScreenState();
}

class _CodigosScreenState extends State<CodigosScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _onCodigoSelected(
    BuildContext context,
    String contribCodigo,
    String nombreCompleto
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _loadingDialog(),
    );
    await Provider.of<CurrentAccountProvider>(
      context,
      listen: false,
    ).getDeudas(contribCodigo);

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();

    final datos = {
      "codigo": contribCodigo,
      "nombreCompleto": nombreCompleto
    };

    Navigator.pushReplacementNamed(
      context,
      'principal',
      arguments: datos);
  }

  Widget _loadingDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Consultando...', style: GoogleFonts.urbanist(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final List<dynamic> datos = authProvider.user?.detalle ?? [];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00296B),
        title: Text(
          "Mis Propiedades",
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Encabezado
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Usted tiene más de un codigo asociado a su DNI.',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00296B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seleccione la vivienda a consultar:',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de propiedades
            Expanded(
              child: ListView.builder(
                itemCount: datos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Consultando...',
                                    style: GoogleFonts.urbanist(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      _onCodigoSelected(context, datos[index].contrib, datos[index].nombreCompleto);

                      /* final currentAccount =
                          Provider.of<CurrentAccountProvider>(
                            context,
                            listen: false,
                          );
                      await currentAccount.getDeudas(datos[index].contrib);

                      if (!mounted) return;

                      Navigator.of(context, rootNavigator: true).pop();

                      Navigator.pushNamed(context, 'principal'); */
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                            child: Image.asset(
                              'images/vivienda.jpg',
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Información
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Contribuyente
                                  Text(
                                    "Contribuyente",
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    datos[index].contrib,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00296B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  //Nombre Completo
                                  Text(
                                    datos[index].nombreCompleto,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00296B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Dirección
                                  Text(
                                    "Dirección",
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    datos[index].direccion,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                            size: 28,
                            color: Color(0xFF00296B),
                          ),
                        ],
                      ),
                    ),
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
