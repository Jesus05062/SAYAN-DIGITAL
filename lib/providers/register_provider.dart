import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sayan_digital/config.dart';

class RegisterProvider extends ChangeNotifier {
  String message = '';
  IconData icon = Icons.info;
  Color color = Colors.grey;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String> register(
    String correo,
    String password,
    String dni,
    String codigoDJ,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ConfigRuta.ApiUrl}cliente/InsertarUsuario');

      // Encriptación Base64 de la contraseña
      final passwordEncriptado = base64Encode(utf8.encode(password));

      final body = jsonEncode({
        'correo': correo,
        'contraseña': passwordEncriptado,
        'dni': dni,
        'codigoDJ': codigoDJ,
      });

      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _setSuccessState(
          'Registro exitoso. Para activar su cuenta revise su Bandeja de Entrada o la carpeta de SPAM.',
        );
        return 'Registro exitoso';
      } else {
        // Manejo de errores 400 y otros
        final Map<String, dynamic> decodeData = jsonDecode(response.body);
        _setErrorState(
          decodeData['mensaje'] ?? 'Error inesperado en el servidor',
        );
        return 'no exitoso';
      }
    } on SocketException {
      _setErrorState('No hay conexión a internet');
      return 'error';
    } catch (e) {
      _setErrorState('Error de conexión: Intentelo más tarde');
      return 'error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setErrorState(String msg) {
    message = msg;
    icon = Icons.sentiment_dissatisfied_rounded;
    color = Colors.redAccent;
  }

  void _setSuccessState(String msg) {
    message = msg;
    icon = Icons.sentiment_satisfied_alt_rounded;
    color = Colors.green;
  }
}
