import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayan_digital/providers/auth_provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sayan_digital/providers/current_account_provider.dart';
import 'package:sayan_digital/widgets/custom_background.dart';
import 'package:sayan_digital/helpers/alert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _dniController = TextEditingController();
  final _claveController = TextEditingController();

  bool _obscurePassword = true;

  final _dniMask = MaskTextInputFormatter(
    mask: '###########',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _dniController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accountProvider = Provider.of<CurrentAccountProvider>(
      context,
      listen: false,
    );
    print("Intentando ingresar con DNI: ${_dniController.text}");
    final success = await authProvider.ingresar(
      _dniController.text,
      _claveController.text,
    );

    if (!mounted) return;

    if (success) {
      final detalles = authProvider.user?.detalle ?? [];

      if (detalles.length > 1) {
        Navigator.pushReplacementNamed(context, 'codigos');
      } else if (detalles.length == 1) {
        print("Detalles: $detalles");
        print("Contribuyente: ${detalles[0].contrib}");
        await accountProvider.getDeudas(detalles[0].contrib);
        if (!mounted) {
          return;
        }
        Navigator.pushReplacementNamed(context, 'principal');
      } else {
        Navigator.pushReplacementNamed(context, 'principal');
      }
    } else {
      displayCustomAlert(
        context: context,
        icon: Icons.error_outline,
        message: authProvider.errorMessage,
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: CustomBackground(
        child: Consumer<AuthProvider>(
          builder: (context, provider, _) {
            return _buildBody(provider);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pushNamed(context, 'inicio'),
      ),
    );
  }

  Widget _buildBody(AuthProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildDniField(),
                const SizedBox(height: 15),
                _buildPasswordField(),
                const SizedBox(height: 30),
                _buildLoginButton(provider),
                const SizedBox(height: 25),
                _buildLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'SAYAN DIGITAL',
          style: GoogleFonts.urbanist(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00296B),
          ),
        ),
        const SizedBox(height: 20),
        Image.asset("images/logo_municipio.png", height: 140),
      ],
    );
  }

  Widget _buildDniField() {
    return TextFormField(
      controller: _dniController,
      inputFormatters: [_dniMask],
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('Número de DNI/RUC'),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ingrese su documento' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _claveController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration('Clave Web').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ingrese su clave' : null,
    );
  }

  Widget _buildLoginButton(AuthProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: provider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Acceder',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, 'registro'),
          child: const Text(
            '¿No tienes tu Clave Web? Registrarse',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, 'validar_dni'),
          child: const Text(
            'Olvidé mi contraseña',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      labelText: label,
    );
  }
}
