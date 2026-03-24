import 'package:flutter/material.dart';

class ConfigRuta {
  //static const url = '192.168.4.230:3000';
  //static const url = 'api-munisayan.fly.dev';
  static const url = 'demo.ed.pe';
  static const String ApiUrl =
      'https://api.munisayan.gob.pe:44351/'; //'https://38.253.80.120:44351/';//'https://wxl1w6r0-7234.brs.devtunnels.ms/'; //'https://192.168.4.19:44351/'; //
}

//https://38.253.80.120:44351/
//https://192.168.4.19:44351/
class InterfaceColor extends MaterialColor {
  static const colorg = Color.fromARGB(255, 95, 209, 43);
  static const colorb = Color.fromRGBO(0, 41, 107, 1);

  static const orangeBtn = Color.fromRGBO(255, 164, 36, 1);
  //static const greenFont = Color.fromRGBO(119,221,119, 1);
  static const greenFont = Color.fromRGBO(56, 201, 56, 1);
  //static const greenFont = Color.fromRGBO(42,157,143, 1);
  //static const greenFont = Color.fromRGBO(169, 233, 164, 1);

  const InterfaceColor(super.primary, super.swatch);
}

class AppSwitches {
  static const bool pagosHabilitados = true; // Controla Checkbox y Botón Pagar
  static const bool mostrarPagados =
      true; // Controla si se listan recibos con Estado 2
}
