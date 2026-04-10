import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sayan_digital/config.dart';
import 'package:sayan_digital/models/current_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentAccountProvider extends ChangeNotifier {
  List<CurrentAccount> _cuentas = [];
  List<CurrentAccount> get cuentas => _cuentas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getDeudas(String contribuyenteCodigo) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        '${ConfigRuta.ApiUrl}clienteJesus/DetallesPredioPorAño?Contribuyente=$contribuyenteCodigo',
      );
      print(url.toString());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      print(token);

      final response = await http.get(url, headers: headers);

      print("Respuesta de estado de cuenta: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        _cuentas = decodedData
            .map((item) => CurrentAccount.fromJson(item))
            .toList();
      } else {
        _cuentas = [];
      }
    } catch (e, stacktrace) {
      _cuentas = [];
      print("Error cargando deudas: $e");
      print("Stacktrace: $stacktrace");
    }

    _isLoading = false;
    notifyListeners();
  }
}
