import 'dart:convert';

class CurrentAccount {
  final int idConfigTributo;
  final String descripcion;
  final double insoluto;
  final double interes;
  final double total;
  final double porPagar;
  final bool isTributo;
  final List<DeudaHijo> hijos;

  CurrentAccount({
    required this.idConfigTributo,
    required this.descripcion,
    required this.insoluto,
    required this.interes,
    required this.total,
    required this.porPagar,
    required this.isTributo,
    required this.hijos,
  });

  factory CurrentAccount.fromJson(Map<String, dynamic> json) {
    return CurrentAccount(
      idConfigTributo: json["Id_Config_Tributo"] ?? 0,
      descripcion: json["Descripcion"] ?? "Sin descripción",
      insoluto: (json["Insoluto"] ?? 0).toDouble(),
      interes: (json["Interes"] ?? 0).toDouble(),
      total: (json["Total"] ?? 0).toDouble(),
      porPagar: (json["PorPagar"] ?? 0).toDouble(),
      isTributo: json["IsTributo"] ?? false,
      hijos: json["hijos"] != null
          ? List<DeudaHijo>.from(json["hijos"].map((x) => DeudaHijo.fromJson(x)))
          : [],
    );
  }
}

class DeudaHijo {
  final int? id;
  final int? idConfigTributo;
  final String? periodoC;
  final double? valorDeuda;
  final double? valorDerechoEmision;
  final double? valorInteres;
  final int? estado;
  final int? ano;
  final String? anoDate;
  final int? periodo;
  final String? fechaVencimiento;
  final String? codigo;
  final double? pago;
  final double? saldo;
  final String? direccionCompleta;
  final String? direccion;
  final List<DeudaDetalle> detalles;

  DeudaHijo({
    this.id,
    this.idConfigTributo,
    this.periodoC,
    this.valorDeuda,
    this.valorDerechoEmision,
    this.valorInteres,
    this.estado,
    this.ano,
    this.anoDate,
    this.periodo,
    this.fechaVencimiento,
    this.codigo,
    this.pago,
    this.saldo,
    this.direccionCompleta,
    this.direccion,
    required this.detalles,
  });

  factory DeudaHijo.fromJson(Map<String, dynamic> json) {
    // Función de seguridad para campos de texto
    String? safeString(dynamic value) {
      if (value == null) return null;
      if (value is Map || value is List) return value.toString();
      return value.toString();
    }

    // Normalización: Si el API manda 'detalles' dentro de 'hijos', los usamos.
    // Si no (como en Predial), el mismo objeto 'hijo' se convierte en el primer detalle.
    List<DeudaDetalle> listaDetalles = [];
    if (json["detalles"] != null && json["detalles"] is List) {
      listaDetalles = List<DeudaDetalle>.from(
          json["detalles"].map((x) => DeudaDetalle.fromJson(x)));
    } else {
      // Caso Predial: El hijo actual es el detalle
      listaDetalles.add(DeudaDetalle.fromJson(json));
    }

    return DeudaHijo(
      id: json["Id"],
      idConfigTributo: json["Id_Config_Tributo"],
      periodoC: safeString(json["PeriodoC"]),
      valorDeuda: (json["ValorDeuda"] ?? 0).toDouble(),
      valorDerechoEmision: (json["ValorDerechoEmision"] ?? 0).toDouble(),
      valorInteres: (json["ValorInteres"] ?? 0).toDouble(),
      estado: json["Estado"],
      // Manejamos la "ñ" de 'Año' de forma segura
      ano: json["Año"] ?? json["Ano"] ?? json["A\u00F1o"],
      anoDate: safeString(json["AñoDate"] ?? json["A\u00F1oDate"]),
      periodo: json["Periodo"],
      fechaVencimiento: safeString(json["FechaVencimiento"]),
      codigo: safeString(json["Codigo"]),
      pago: (json["Pago"] ?? 0).toDouble(),
      saldo: (json["Saldo"] ?? 0).toDouble(),
      direccionCompleta: safeString(json["DireccionCompleta"]),
      direccion: safeString(json["direccion"]), 
      detalles: listaDetalles,
    );
  }
}

class DeudaDetalle {
  final int? id;
  final int? ano;
  final String? periodoC;
  final double? valorDeuda;
  final double? valorDerechoEmision;
  final double? valorInteres;
  final double? pago;
  final double? saldo;
  final int? estado;

  DeudaDetalle({
    this.id,
    this.ano,
    this.periodoC,
    this.valorDeuda,
    this.valorDerechoEmision,
    this.valorInteres,
    this.pago,
    this.saldo,
    this.estado,
  });

  factory DeudaDetalle.fromJson(Map<String, dynamic> json) {
    String? safeString(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value.toString();
      return value.toString();
    }

    return DeudaDetalle(
      id: json["Id"],
      ano: json["Año"] ?? json["Ano"] ?? json["A\u00F1o"],
      periodoC: safeString(json["PeriodoC"]),
      valorDeuda: (json["ValorDeuda"] ?? 0).toDouble(),
      valorDerechoEmision: (json["ValorDerechoEmision"] ?? 0).toDouble(),
      valorInteres: (json["ValorInteres"] ?? 0).toDouble(),
      pago: (json["Pago"] ?? 0).toDouble(),
      saldo: (json["Saldo"] ?? 0).toDouble(),
      estado: json["Estado"],
    );
  }
}