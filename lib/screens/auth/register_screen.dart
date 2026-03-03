import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../helpers/alert.dart';
import 'package:sayan_digital/providers/register_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _txtDni = TextEditingController();
  final _txtCorreo = TextEditingController();
  final _txtContra = TextEditingController();
  final _txtConfirContra = TextEditingController();
  final _txtCodigoDJ = TextEditingController();

  // State
  bool _isObscure = true;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;

  final _dniMask = MaskTextInputFormatter(
    mask: '###########',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _codigoDJMask = MaskTextInputFormatter(
    mask: '########',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _txtDni.dispose();
    _txtCorreo.dispose();
    _txtContra.dispose();
    _txtConfirContra.dispose();
    _txtCodigoDJ.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _isPasswordEightCharacters = value.length >= 8;
      _hasPasswordOneNumber = value.contains(RegExp(r'[0-9]'));
    });
  }

  void _limpiarCampos() {
    _txtDni.clear();
    _txtCorreo.clear();
    _txtContra.clear();
    _txtConfirContra.clear();
    _txtCodigoDJ.clear();
  }

  @override
  Widget build(BuildContext context) {
    final registroProv = Provider.of<RegisterProvider>(context);

    const primaryColor = Color(0xFF00296B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola!\nRegístrese para comenzar',
                        style: GoogleFonts.urbanist(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildLabel("Correo Electrónico"),
                      TextFormField(
                        controller: _txtCorreo,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('ejemplo@gmail.com'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Ingrese su correo'
                            : (!EmailValidator.validate(value))
                            ? 'Correo no válido'
                            : null,
                      ),

                      const SizedBox(height: 20),
                      _buildLabel("DNI / RUC"),
                      TextFormField(
                        controller: _txtDni,
                        inputFormatters: [_dniMask],
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('# # # # # # # #'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Ingrese su documento'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      _buildLabelWithHelp(
                        "Código DJ",
                        onHelpTap: () => _showHelpDialog(
                          context,
                          "¿Dónde está mi Código DJ?",
                          "images/codigo_dj_help.jpg",
                        ),
                      ),
                      TextFormField(
                        controller: _txtCodigoDJ,
                        inputFormatters: [_codigoDJMask],
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('_ _ _ _ _ _ _ _'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Ingrese su código DJ'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 20),
                      _buildLabel("Genere su Clave Web"),
                      TextFormField(
                        controller: _txtContra,
                        obscureText: _isObscure,
                        onChanged: _onPasswordChanged,
                        decoration: _inputDecoration('Contraseña').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _isObscure = !_isObscure),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Ingrese una contraseña'
                            : null,
                      ),

                      const SizedBox(height: 15),
                      _PasswordCheckRow(
                        label: "Mínimo 8 caracteres",
                        isValid: _isPasswordEightCharacters,
                      ),
                      const SizedBox(height: 8),
                      _PasswordCheckRow(
                        label: "Al menos un número",
                        isValid: _hasPasswordOneNumber,
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _txtConfirContra,
                        obscureText: true,
                        decoration: _inputDecoration('Confirmar contraseña'),
                        validator: (value) {
                          if (value != _txtContra.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: primaryColor.withValues(
                              alpha: 0.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: registroProv.isLoading
                              ? null
                              : () => _handleRegister(context),
                          child: registroProv.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'REGISTRAR',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF00296B),
        ),
      ),
    );
  }

  Widget _buildLabelWithHelp(String text, {VoidCallback? onHelpTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF00296B),
            ),
          ),
          if (onHelpTap != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onHelpTap,
              child: const Icon(
                Icons.help_outline,
                size: 18,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String title, String assetPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Aquí puedes encontrar tu código en tu documento físico.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7F8F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00296B), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Quitar el foco del teclado
    FocusScope.of(context).unfocus();

    final registroProvider = Provider.of<RegisterProvider>(
      context,
      listen: false,
    );

    final response = await registroProvider.register(
      _txtCorreo.text.trim(),
      _txtContra.text,
      _txtDni.text,
      _txtCodigoDJ.text,
    );

    // Si la pantalla se cerró durante la petición, no se realiza la peticion de mostrar la alerta
    if (!mounted) return;

    await displayCustomAlert(
      context: context,
      icon: registroProvider.icon,
      message: registroProvider.message,
      color: registroProvider.color,
    );

    if (response == 'Registro exitoso') {
      _limpiarCampos();
      // Navigator.pushReplacementNamed(context, 'login');
    }
  }
}

class _PasswordCheckRow extends StatelessWidget {
  final String label;
  final bool isValid;

  const _PasswordCheckRow({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isValid ? Colors.green : Colors.transparent,
            border: Border.all(
              color: isValid ? Colors.transparent : Colors.grey.shade400,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: isValid ? Colors.green.shade700 : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
