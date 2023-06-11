class ProgdiModels {
  final String namaProgdi;
  final String kodeProgdi;

  ProgdiModels({
    required this.namaProgdi,
    required this.kodeProgdi,
  });

  factory ProgdiModels.fromJson(Map<String, dynamic> json) {
    return ProgdiModels(
      namaProgdi: json['nama_progdi'],
      kodeProgdi: json['kode_progdi'],
    );
  }
}
