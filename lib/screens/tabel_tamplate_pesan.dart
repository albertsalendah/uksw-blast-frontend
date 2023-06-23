import 'dart:convert';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/template_pesan.dart';
import '../utils/link.dart';

class DataTableTemplatePesan extends StatefulWidget {
  final TextEditingController kategoriPesanController;

  final TextEditingController isiPesanController;
  const DataTableTemplatePesan(
      {super.key,
      //required this.daftar_template,
      required this.kategoriPesanController,
      required this.isiPesanController});

  @override
  _DataTableTemplatePesan createState() => _DataTableTemplatePesan();
}

class _DataTableTemplatePesan extends State<DataTableTemplatePesan> {
  List<Template_Pesan> daftar_template = [];
  final int rowsPerPage = 10;
  int currentPage = 0;
  final String link = Links().link;
  //List<Template_Pesan> daftar_template = [];

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
      });
    } else {
      // Error fetching data
      print('Failed to fetch messages from MongoDB');
    }
  }

  Future<void> deleteTemplatePesan(String messageId) async {
    final url = '${link}delete_template_pesan/$messageId';

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      // Data deleted successfully
      print('Data deleted from MongoDB');
      setState(() {});
    } else {
      // Error deleting data
      print('Failed to delete data from MongoDB');
    }
  }

  Future<void> _updateTemplatePesan(String id) async {
    final String kategoriPesan = widget.kategoriPesanController.text;
    final String isiPesan = widget.isiPesanController.text;

    // Send the update request to the backend API
    final response = await http.put(
      Uri.parse('${link}edit_template_pesan/${id}'),
      body: {
        'kategori_pesan': kategoriPesan,
        'isi_pesan': isiPesan,
      },
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      setState(() {
        //fetchdaftarTemplate();
        //showdaftarTemplateAlertDialog();
      });
    } else {
      // Update failed
      // You can handle the error case based on your requirements
      print('Update failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
     if (daftar_template.isEmpty) {
    // Show a loading indicator or a message while waiting for data
    return AlertDialog(
      title: const Text('Daftar Template Pesan'),
      content: const Text('Loading...'),
    );
  } else {
    return AlertDialog(
      title: const Text('Daftar Template Pesan'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(10),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('Kategori Pesan'),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Isi Pesan'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('Action'),
                    ),
                  ],
                ),
              ),

              // Table Rows
              if (paginatedList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: paginatedList.length,
                  itemBuilder: (context, index) {
                    final item = paginatedList[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () {
                                widget.kategoriPesanController.text =
                                    item.kategoriPesan;
                                widget.isiPesanController.text = item.isiPesan;
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(item.kategoriPesan),
                                  ),
                                  Expanded(
                                      flex: 2,
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
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      //final updatedItem =
                                      //daftar_template[index];
                                      //_showUpdateDialog(updatedItem);
                                    },
                                    icon: const Icon(Icons.edit)),
                                const SizedBox(
                                  width: 8,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    deleteTemplatePesan(
                                        daftar_template[index].id);
                                    setState(() {});
                                    // ignore: use_build_context_synchronously
                                    //Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
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
                    icon: Icon(Icons.chevron_left),
                    onPressed: currentPage > 0
                        ? () => goToPage(currentPage - 1)
                        : null,
                  ),
                  Text('Page ${currentPage + 1}'),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed:
                        (currentPage + 1) * rowsPerPage < daftar_template.length
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
}
