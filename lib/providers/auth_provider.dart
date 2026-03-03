import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sayan_digital/config.dart';
import 'dart:convert';
//import 'dart:convert' as convert;
import 'package:sayan_digital/models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserResponse? _user;
  UserResponse? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<bool> ingresar(String dni, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final passBase64 = base64Encode(utf8.encode(password));
      final url = Uri.parse(
        '${ConfigRuta.ApiUrl}cliente/Logeo?Documento=$dni&Password=$passBase64',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      final decodedData = jsonDecode(response.body);

      if (decodedData is List) {
        _errorMessage = decodedData[0]['mensaje'] ?? 'Error desconocido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = UserResponse.fromJson(decodedData);

      if (_user!.activo && response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _user!.token ?? '');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _user!.mensaje;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión con el servidor';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
