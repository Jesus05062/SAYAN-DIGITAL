class UserResponse {
  final String? correo;
  final bool activo;
  final String mensaje;
  final String? token;
  final int expiresIn;
  final List<DetalleContribuyente> detalle;

  UserResponse({
    this.correo,
    required this.activo,
    required this.mensaje,
    this.token,
    required this.expiresIn,
    required this.detalle,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    correo: json["correo"],
    activo: json["activo"] ?? false,
    mensaje: json["mensaje"] ?? "",
    token: json["token"],
    expiresIn: json["expiresIn"] ?? 0,
    detalle: json["detalle"] == null
        ? []
        : List<DetalleContribuyente>.from(
            json["detalle"].map((x) => DetalleContribuyente.fromJson(x)),
          ),
  );
}

class DetalleContribuyente {
  final String contrib;
  final String nombreCompleto;
  final String direccion;

  DetalleContribuyente({
    required this.contrib,
    required this.nombreCompleto,
    required this.direccion,
  });

  factory DetalleContribuyente.fromJson(Map<String, dynamic> json) =>
      DetalleContribuyente(
        contrib: json["contrib"] ?? "",
        nombreCompleto: json["nombreCompleto"] ?? "",
        direccion: json["direccion"] ?? "",
      );
}
