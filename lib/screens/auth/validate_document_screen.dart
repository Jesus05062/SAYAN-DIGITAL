// ignore_for_file: use_build_context_synchronously

import 'package:sayan_digital/helpers/alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sayan_digital/providers/change_password_provider.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.15),
    builder: (_) {
      return Center(
        child: Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(0.15),
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF003366),
          ),
        ),
      );
    },
  );
}

class ValidarDni extends StatefulWidget {
  const ValidarDni({super.key});

  @override
  State<ValidarDni> createState() => _ValidarDniState();
}

class _ValidarDniState extends State<ValidarDni> {
  var dniMask = MaskTextInputFormatter(
      mask: '###########', filter: {"#": RegExp(r'[0-9]')});

  final _formKey = GlobalKey<FormState>();
  final txtDni = TextEditingController();

  String dni = '';

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset(
              'images/intro.jpg',
              height: screen.height * 0.25,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Restablecer Contraseña',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se enviará un código a su correo registrado',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DNI / RUC',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF003366),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      inputFormatters: [dniMask],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '########',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF7F8F9),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      controller: txtDni,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ingrese su DNI o RUC';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                        ),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          dni = txtDni.text.trim();

                          final cambioPasswordProvider =
                              Provider.of<ChangePasswordProvider>(context,
                                  listen: false);

                          /// Mostrar loader profesional
                          showLoadingDialog(context);

                          final response =
                              await cambioPasswordProvider.validateDocument(dni);

                          /// Cerrar loader
                          Navigator.pop(context);

                          if (response) {
                            // Navegar automáticamente al ingreso del código
                            Navigator.pushReplacementNamed(
                                context, 'validar_cambio_password');
                          } else if (response == false) {
                            displayCustomAlert(
                                title: 'ALERTA',
                                context: context,
                                icon: cambioPasswordProvider.icon,
                                message: cambioPasswordProvider.message,
                                color: cambioPasswordProvider.color);

                            Future.delayed(const Duration(seconds: 10), () {
                              Navigator.pop(context);
                            });
                          } else {
                            displayCustomAlert(
                              title: 'ALERTA',
                              context: context,
                              icon: cambioPasswordProvider.icon,
                              message: cambioPasswordProvider.message,
                              color: cambioPasswordProvider.color,
                            );
                          }
                        },
                        child: Text(
                          'Enviar Código',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  //Widget _buildValidatorButton()
}
