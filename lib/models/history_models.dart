class history_models {
  String? sId;
  String? tanggal;
  String? no_pendaftaran;
  String? nama;
  String? tahun_ajaran;
  String? progdi;
  String? pesan;
  String? status_registrasi;
  int? iV;

  history_models(
      {this.sId,
      this.tanggal,
      this.no_pendaftaran,
      this.nama,
      this.tahun_ajaran,
      this.progdi,
      this.pesan,
      this.status_registrasi,
      this.iV});

  history_models.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    tanggal = json['tanggal'];
    no_pendaftaran = json['no_pendaftaran'];
    nama = json['nama'];
    tahun_ajaran = json['tahun_ajaran'];
    progdi = json['progdi'];
    pesan = json['pesan'];
    status_registrasi = json['status_registrasi'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['tanggal'] = this.tanggal;
    data['no_pendaftaran'] = this.no_pendaftaran;
    data['nama'] = this.nama;
    data['tahun_ajaran'] = this.tahun_ajaran;
    data['progdi'] = this.progdi;
    data['pesan'] = this.pesan;
    data['status_registrasi'] = this.status_registrasi;
    data['__v'] = this.iV;
    return data;
  }
}