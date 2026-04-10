import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sayan_digital/config.dart';

class ChangePasswordProvider extends ChangeNotifier {
  String message = '';
  IconData icon = Icons.info;
  Color color = Colors.grey;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<bool> validateDocument(String documento) async {
    _isLoading = true;
    _errorMessage = '';

    notifyListeners();

    try {
      final url = Uri.parse(
        '${ConfigRuta.ApiUrl}cliente/RestablecerContrasena?Documento=$documento',
      );

      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _setSuccessState(
          '¡Validación exitosa! \n Hemos enviado un código de verificación al correo electrónico vinculado a tu cuenta. Por favor, revisa tu bandeja de entrada (y la carpeta de spam) para continuar con el restablecimiento.',
        );
        return true;
      } else {
        final Map<String, dynamic> decodeData = jsonDecode(response.body);
        _setErrorState(
          decodeData['mensaje'] ?? 'Error inesperado en el servidor',
        );
        return false;
      }
    } on SocketException {
      _setErrorState('No hay conexión a internet');
      return false;
    } catch (e) {
      _setErrorState('Error de conexión: Intentelo más tarde - ${e}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(
    String password,
    String document,
    String code,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ConfigRuta.ApiUrl}cliente/CambioContrasena');
      final passwordEncrypted = base64Encode(utf8.encode(password));
      final body = {
        "contraseña": passwordEncrypted,
        "dni": document,
        "codigo": code,
      };

      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        _setSuccessState(
          '¡Cambio exitoso! \n Se actualizó su contraseña con éxito',
        );
        return true;
      }else {
        // Manejo de errores 400 y otros
        final Map<String, dynamic> decodeData = jsonDecode(response.body);
        _setErrorState(
          decodeData['mensaje'] ?? 'Error inesperado en el servidor',
        );
        return false;
      }
    } on SocketException {
      _setErrorState('No hay conexión a internet');
      return false;
    } catch (e) {
      _setErrorState('Error de conexión: Intentelo más tarde - ${e}');
      return false;
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
