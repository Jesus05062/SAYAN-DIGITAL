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
  // Nota: Algunos hijos vienen con datos directos y otros con una lista de 'detalles'
  final int? id;
  final String? periodoC;
  final double? saldo;
  final String? direccion; // Para tributos tipo Limpieza/Serenazgo
  final List<DeudaDetalle> detalles;

  DeudaHijo({
    this.id,
    this.periodoC,
    this.saldo,
    this.direccion,
    required this.detalles,
  });

  factory DeudaHijo.fromJson(Map<String, dynamic> json) => DeudaHijo(
    id: json["Id"],
    periodoC: json["PeriodoC"],
    saldo: (json["Saldo"] ?? 0).toDouble(),
    direccion: json["direccion"],
    detalles: json["detalles"] == null
        ? []
        : List<DeudaDetalle>.from(
            json["detalles"].map((x) => DeudaDetalle.fromJson(x)),
          ),
  );
}

class DeudaDetalle {
  final int id;
  final String periodoC;
  final double valorDeuda;
  final double saldo;
  final int anio;

  DeudaDetalle({
    required this.id,
    required this.periodoC,
    required this.valorDeuda,
    required this.saldo,
    required this.anio,
  });

  factory DeudaDetalle.fromJson(Map<String, dynamic> json) => DeudaDetalle(
    id: json["Id"] ?? 0,
    periodoC: json["PeriodoC"] ?? "",
    valorDeuda: (json["ValorDeuda"] ?? 0).toDouble(),
    saldo: (json["Saldo"] ?? 0).toDouble(),
    anio: json["Año"] ?? 0,
  );
}
