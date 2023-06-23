class history_models {
  String? id_pesan;
  String? Nama;
  String? No_Handphone;
  String? Kategori_Pesan;
  String? Status_Pesan;
  

  history_models(
      {this.id_pesan,
      this.Nama,
      this.No_Handphone,
      this.Kategori_Pesan,
      this.Status_Pesan,
      });

  history_models.fromJson(Map<String, dynamic> json) {
    id_pesan = json['id_pesan'];
    Nama = json['Nama'];
    No_Handphone = json['No_Handphone'];
    Kategori_Pesan = json['Kategori_Pesan'];
    Status_Pesan = json['Status_Pesan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_pesan'] = this.id_pesan;
    data['Nama'] = this.Nama;
    data['No_Handphone'] = this.No_Handphone;
    data['Kategori_Pesan'] = this.Kategori_Pesan;
    data['Status_Pesan'] = this.Status_Pesan;
    return data;
  }
}