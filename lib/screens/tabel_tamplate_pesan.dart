// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/template_pesan.dart';
import '../utils/config.dart';
import '../utils/link.dart';
import 'notif_screen.dart';

class DataTableTemplatePesan extends StatefulWidget {
  final TextEditingController kategoriPesanController;
  final TextEditingController isiPesanController;
  final Function(String) templatepick;
  const DataTableTemplatePesan(
      {super.key,
      required this.kategoriPesanController,
      required this.isiPesanController,
      required this.templatepick});

  @override
  _DataTableTemplatePesan createState() => _DataTableTemplatePesan();
}

class _DataTableTemplatePesan extends State<DataTableTemplatePesan> {
  List<Template_Pesan> daftar_template = [];
  final int rowsPerPage = 10;
  int currentPage = 0;
  final String link = Links().link;
  final TextEditingController editKategoriPesan = TextEditingController();
  final TextEditingController editIsiPesan = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<Template_Pesan> paginatedList = [];

  @override
  void initState() {
    super.initState();
    paginateList();
    fetchdaftarTemplate();
  }

  void paginateList() {
    final startIndex = currentPage * rowsPerPage;
    final endIndex = startIndex + rowsPerPage;

    if (startIndex < daftar_template.length) {
      setState(() {
        paginatedList = daftar_template.sublist(
          startIndex,
          endIndex.clamp(0, daftar_template.length),
        );
      });
    }
  }

  void goToPage(int page) {
    setState(() {
      currentPage = page;
      searchController.text = '';
      paginateList();
    });
  }

  Future<void> fetchdaftarTemplate() async {
    final url = '${link}daftar_template';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      final List<Template_Pesan> fetchedMessages = responseData
          .map((daftar_template) => Template_Pesan(
                id: daftar_template['_id'],
                kategoriPesan: daftar_template['kategori_pesan'],
                isiPesan: daftar_template['isi_pesan'],
              ))
          .toList();
      setState(() {
        daftar_template = fetchedMessages;
        paginateList();
      });
    } else {
      NOTIF_SCREEN().popUpError(context, MediaQuery.of(context).size.width,
          "Gagal Mengambil Data Dari Database");
    }
  }

  Future<void> deleteTemplatePesan(String messageId) async {
    final url = '${link}delete_template_pesan/$messageId';

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      // Data deleted successfully
      NOTIF_SCREEN().popUpSuccess(
          context,
          MediaQuery.of(context).size.width,
          "Berhasil Menghapus Data Dari Database");
      fetchdaftarTemplate();
    } else {
      NOTIF_SCREEN().popUpError(context, MediaQuery.of(context).size.width,
          "Gagal Menghapus Data Dari Database");
    }
  }

  Future<void> _updateTemplatePesan(String id) async {
    final String kategoriPesan = editKategoriPesan.text;
    final String isiPesan = editIsiPesan.text;

    // Send the update request to the backend API
    final response = await http.put(
      Uri.parse('${link}edit_template_pesan/$id'),
      body: {
        'kategori_pesan': kategoriPesan,
        'isi_pesan': isiPesan,
      },
    );

    if (response.statusCode == 200) {
      NOTIF_SCREEN().popUpSuccess(
          context,
          MediaQuery.of(context).size.width,
          "Berhasil Mengubah Data Dari Database");
      fetchdaftarTemplate();
    } else {
      NOTIF_SCREEN().popUpError(context, MediaQuery.of(context).size.width,
          "Gagal Mengubah Data Dari Database");
    }
  }

  List<Template_Pesan> get filteredList {
    if (searchController.text.isEmpty) {
      return paginatedList;
    } else {
      return daftar_template.where((item) {
        final nama = item.kategoriPesan.toLowerCase();
        return nama.contains(searchController.text.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width =MediaQuery.of(context).size.width;
    if (paginatedList.isEmpty) {
      // Show a loading indicator or a message while waiting for data
      return const AlertDialog(
        title: Text('Daftar Template Pesan'),
        content: Text('Loading...'),
      );
    } else {
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
            title: Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Config().green,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Daftar Template Pesan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        content: SizedBox(
          width: (width > 827) ? MediaQuery.of(context).size.width / 1.7 : 500,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Table Header
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('Kategori Pesan'),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('Isi Pesan'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Action'),
                      ),
                    ],
                  ),
                ),

                // Table Rows
                if (filteredList.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isEven = index % 2 == 0;
                      final backgroundColor =
                          isEven ? Colors.grey[200] : Colors.white;
                      final borderColor =
                          isEven ? Colors.grey[400] : Colors.grey[200];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: borderColor!,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          color: backgroundColor,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: InkWell(
                                onTap: () {
                                  widget.kategoriPesanController.text =
                                      item.kategoriPesan;
                                  widget.isiPesanController.text =
                                      item.isiPesan;
                                  widget.templatepick(item.isiPesan);
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(item.kategoriPesan),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: ExpandableText(
                                          item.isiPesan,
                                          expandText: 'show more',
                                          collapseText: 'show less',
                                          //maxLines: 1,
                                          linkColor: Colors.blue,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      final updatedItem =
                                          daftar_template[index];
                                      _showUpdateDialog(updatedItem,width);
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.grey,
                                    )),
                                const SizedBox(
                                  width: 8,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.grey),
                                  onPressed: () {
                                    AwesomeDialog(
                                      width:(width > 830) ? width / 2 : 350,
                                      context: context,
                                      showCloseIcon: true,
                                      closeIcon: const Icon(
                                        Icons.close_rounded,
                                      ),
                                      animType: AnimType.scale,
                                      dialogType: DialogType.question,
                                      title: 'Delete',
                                      desc: "Hapus ${item.kategoriPesan} ?",
                                      btnOkOnPress: () {
                                        deleteTemplatePesan(
                                            daftar_template[index].id);
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // Pagination Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage > 0
                          ? () => goToPage(currentPage - 1)
                          : null,
                    ),
                    Text('Page ${currentPage + 1}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: (currentPage + 1) * rowsPerPage <
                              daftar_template.length
                          ? () => goToPage(currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _showUpdateDialog(Template_Pesan currentItem,double width) {
    editKategoriPesan.text = currentItem.kategoriPesan;
    editIsiPesan.text = currentItem.isiPesan;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Config().green,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Update Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
            content: SizedBox(
              width: (width > 827) ? MediaQuery.of(context).size.width / 1.7 : 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: editKategoriPesan,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Pesan',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      controller: editIsiPesan,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          labelText: 'Isi Pesan'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _updateTemplatePesan(currentItem.id);
                    Navigator.of(context).pop();
                  });
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}
