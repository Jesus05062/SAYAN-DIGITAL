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

  factory CurrentAccount.fromJson(Map<String, dynamic> json) => CurrentAccount(
    idConfigTributo: json["Id_Config_Tributo"] ?? 0,
    descripcion: json["Descripcion"] ?? "",
    insoluto: (json["Insoluto"] ?? 0).toDouble(),
    interes: (json["Interes"] ?? 0).toDouble(),
    total: (json["Total"] ?? 0).toDouble(),
    porPagar: (json["PorPagar"] ?? 0).toDouble(),
    isTributo: json["IsTributo"] ?? false,
    hijos: json["hijos"] == null
        ? []
        : List<DeudaHijo>.from(json["hijos"].map((x) => DeudaHijo.fromJson(x))),
  );
}

class DeudaHijo {
  final int? id;
  final int? idConfigTributo;
  final String? periodoC;
  final double? valorDeuda;
  final double? valorDerechoEmision;
  final double? valorIntereses;
  final int? estado;
  final int? ano;
  final String? anoDate;
  final int? periodo;
  final String? fechaVencimiento;
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
    this.valorIntereses,
    this.estado,
    this.ano,
    this.anoDate,
    this.periodo,
    this.fechaVencimiento,
    this.pago,
    this.saldo,
    this.direccionCompleta,
    this.direccion,
    required this.detalles,
  });

  factory DeudaHijo.fromJson(Map<String, dynamic> json) => DeudaHijo(
    id: json["Id"] ?? 0,
    idConfigTributo: json["Id_Config_Tributo"] ?? 0,
    periodoC: json["PeriodoC"] ?? "",
    valorDeuda: (json["ValorDeuda"] ?? 0).toDouble(),
    valorDerechoEmision: (json["ValorDerechoEmision"] ?? 0).toDouble(),
    valorIntereses: (json["ValorIntereses"] ?? 0).toDouble(),
    estado: json["Estado"] ?? 0,
    ano: json["Año"] ?? 0,
    anoDate: json["AñoDate"] ?? "",
    periodo: json["Periodo"] ?? 0,
    fechaVencimiento: json["FechaVencimiento"] ?? "",
    pago: (json["Pago"] ?? 0).toDouble(),
    saldo: (json["Saldo"] ?? 0).toDouble(),
    direccionCompleta: json["direccionCompleta"] ?? "",
    direccion: json["direccion"] ?? "",
    detalles: json["detalles"] == null
        ? []
        : List<DeudaDetalle>.from(
            json["detalles"].map((x) => DeudaDetalle.fromJson(x)),
          ),
  );
}

class DeudaDetalle {
  final int id;
  final int? idConfigTributo;
  final String? periodoC;
  final double? valorDeuda;
  final double? valorDerechoEmision;
  final double? valorIntereses;
  final int? estado;
  final int? ano;
  final String? anoDate;
  final int? periodo;
  final String? fechaVencimiento;
  final double? pago;
  final double? saldo;
  final String? direccionCompleta;

  DeudaDetalle({
    required this.id,
    this.idConfigTributo,
    this.periodoC,
    this.valorDeuda,
    this.valorDerechoEmision,
    this.valorIntereses,
    this.estado,
    this.ano,
    this.anoDate,
    this.periodo,
    this.fechaVencimiento,
    this.pago,
    this.saldo,
    this.direccionCompleta,
  });

  factory DeudaDetalle.fromJson(Map<String, dynamic> json) => DeudaDetalle(
    id: json["Id"] ?? 0,
    idConfigTributo: json["Id_Config_Tributo"] ?? 0,
    periodoC: json["PeriodoC"] ?? "",
    valorDeuda: (json["ValorDeuda"] ?? 0).toDouble(),
    valorDerechoEmision: (json["ValorDerechoEmision"] ?? 0).toDouble(),
    valorIntereses: (json["ValorIntereses"] ?? 0).toDouble(),
    estado: json["Estado"] ?? 0,
    ano: json["Año"] ?? 0,
    anoDate: json["AñoDate"] ?? "",
    periodo: json["Periodo"] ?? 0,
    fechaVencimiento: json["FechaVencimiento"] ?? "",
    pago: (json["Pago"] ?? 0).toDouble(),
    saldo: (json["Saldo"] ?? 0).toDouble(),
    direccionCompleta: json["direccionCompleta"] ?? "",
  );
}
