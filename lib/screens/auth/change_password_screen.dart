// ignore_for_file: use_build_context_synchronously

import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sayan_digital/helpers/alert.dart';
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

class ValidarCambio extends StatefulWidget {
  const ValidarCambio({super.key});

  @override
  State<ValidarCambio> createState() => _ValidarCambioState();
}

class _ValidarCambioState extends State<ValidarCambio> {
  final _formKey = GlobalKey<FormState>();

  final txtContra = TextEditingController();
  final txtDni = TextEditingController();
  final txtCodigo = TextEditingController();

  var dniMask = MaskTextInputFormatter(mask: '###########', filter: {"#": RegExp(r'[0-9]')});
  var codigoMask = MaskTextInputFormatter(mask: '######', filter: {"#": RegExp(r'[A-Za-z0-9]')});

  bool _isVisible = true;

  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;

  late int endTime;

  @override
  void initState() {
    super.initState();
    endTime = DateTime.now().millisecondsSinceEpoch + 180000; // 3 min
  }

  void limpiarCampos() {
     txtDni.clear();
     txtContra.clear();
     txtCodigo.clear();
  }

  onPasswordChanged(String value) {
    final numericRegex = RegExp(r'[0-9]');

    setState(() {
      _isPasswordEightCharacters = value.length >= 8;
      _hasPasswordOneNumber = numericRegex.hasMatch(value);
    });
  }

  void _tiempoAgotado() async {
    displayCustomAlert(
      title: "Tiempo agotado",
      context: context,
      icon: Icons.timer_off_outlined,
      color: Colors.red,
      message: "El código de verificación expiró. Solicítelo nuevamente.",
    );

    await Future.delayed(const Duration(seconds: 3));

    Navigator.pushNamedAndRemoveUntil(context, 'validar_dni', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(226, 248, 199, 53),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, 'validar_dni', (route) => false);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                // Banner
                SizedBox(
                  width: 400,
                  height: 170,
                  child: Image.asset("images/intro.jpg"),
                ),

                const SizedBox(height: 5),

                Text("Restablecer Contraseña",
                    style: GoogleFonts.aclonica(
                        textStyle: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(0, 41, 107, 1)))),

                Text("Revise su bandeja de Recibidos o Spam",
                    style: GoogleFonts.akshar(fontSize: 18)),

                const SizedBox(height: 20),

                // DNI
                _buildLabel("DNI / RUC :"),
                _buildDniField(),

                const SizedBox(height: 20),

                // Contraseña nueva
                _buildLabel("Nueva contraseña :"),
                const SizedBox(height: 20),
                _buildPasswordField(),

                const SizedBox(height: 15),
                _buildPasswordRules(),

                const SizedBox(height: 20),

                // Código + contador
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLabel("Validar Código :"),
                    CountdownTimer(
                      endTime: endTime,
                      onEnd: _tiempoAgotado,
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    _buildCodigoField(),
                  ],
                ),

                const SizedBox(height: 20),

                // Botón Validar
                _buildBotonValidar(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================== WIDGETS ============================= //

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 20),
      child: Text(
        text,
        style: GoogleFonts.urbanist(
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color.fromRGBO(0, 41, 107, 1),
          ),
        ),
      ),
    );
  }

  Widget _buildDniField() {
    return SizedBox(
      width: 240,
      child: TextFormField(
        controller: txtDni,
        inputFormatters: [dniMask],
        keyboardType: TextInputType.number,
        decoration: _decoracion("########"),
        validator: (value) =>
            value == null || value.isEmpty ? "Ingrese su DNI/RUC" : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      width: 280,
      child: TextFormField(
        controller: txtContra,
        obscureText: _isVisible,
        decoration: _decoracion("Contraseña").copyWith(
          labelText: "Contraseña",
          suffixIcon: IconButton(
            icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _isVisible = !_isVisible),
          ),
        ),
        onChanged: onPasswordChanged,
        validator: (value) =>
            value == null || value.isEmpty ? "Ingrese su contraseña" : null,
      ),
    );
  }

  Widget _buildPasswordRules() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _checkCircle(_isPasswordEightCharacters),
            const SizedBox(width: 10),
            const Text("Contiene al menos 8 caracteres"),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _checkCircle(_hasPasswordOneNumber),
            const SizedBox(width: 10),
            const Text("Contiene al menos 1 número"),
          ],
        ),
      ],
    );
  }

  Widget _buildCodigoField() {
    return SizedBox(
      width: 110,
      child: TextFormField(
        controller: txtCodigo,
        inputFormatters: [codigoMask],
        decoration: _decoracion("_ _ _ _ _ _"),
        onChanged: (value) {
          txtCodigo.value = txtCodigo.value.copyWith(
            text: value.toUpperCase(),
            selection:
                TextSelection.collapsed(offset: value.toUpperCase().length),
          );
        },
        validator: (value) =>
            value == null || value.isEmpty ? "Ingrese el código" : null,
      ),
    );
  }

  Widget _buildBotonValidar() {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0xFF003366)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
        ),
        onPressed: _validarCambio,
        child: Text(
          "Validar",
          style: GoogleFonts.urbanist(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  // Decoración base
  InputDecoration _decoracion(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color.fromRGBO(247, 248, 249, 1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color.fromRGBO(232, 236, 244, 1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color.fromRGBO(232, 236, 244, 1)),
      ),
    );
  }

  // Check animado
  Widget _checkCircle(bool enabled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: enabled ? Colors.green : Colors.transparent,
        border: Border.all(color: enabled ? Colors.transparent : Colors.grey),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 15),
    );
  }

  // ============================== LOGICA ============================== //

  Future<void> _validarCambio() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ChangePasswordProvider>(context, listen: false);

    final dni = txtDni.text;
    final pass = txtContra.text;
    final code = txtCodigo.text;

    showLoadingDialog(context);

    final response = await provider.changePassword(dni, pass, code);

    Navigator.pop(context); // cerrar loader

    if (response) {
      limpiarCampos();

      displayCustomAlert(
        context: context,
        icon: provider.icon,
        message: provider.message,
        color: provider.color,
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushNamedAndRemoveUntil(context, "acceder", (route) => false);

    } else {
      displayCustomAlert(
        context: context,
        icon: provider.icon,
        message: provider.message,
        color: provider.color,
      );
    }
  }

}
