// ignore_for_file: library_private_types_in_public_api

import 'package:blast_whatsapp/models/history_models.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';

class DataTablePesan extends StatefulWidget {
  final List<history_models> listPesan;
  const DataTablePesan({super.key, required this.listPesan});

  @override
  _DataTablePesanState createState() => _DataTablePesanState();
}

class _DataTablePesanState extends State<DataTablePesan> {
  final int rowsPerPage = 20;
  int currentPage = 0;
  List<history_models> paginatedList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    paginateList();
  }

  @override
  void didUpdateWidget(covariant DataTablePesan oldWidget) {
    if (oldWidget.listPesan != widget.listPesan) {
      currentPage = 0;
      paginateList();
    }
    super.didUpdateWidget(oldWidget);
  }

  void paginateList() {
    final startIndex = currentPage * rowsPerPage;
    final endIndex = startIndex + rowsPerPage;
    if (startIndex < widget.listPesan.length) {
      setState(() {
        paginatedList = widget.listPesan.sublist(
          startIndex,
          endIndex.clamp(0, widget.listPesan.length),
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

  List<history_models> get filteredList {
    if (searchController.text.isEmpty) {
      return paginatedList;
    } else {
      return widget.listPesan.where((item) {
        final nama = item.Nama?.toLowerCase() ?? '';
        final noHandphone = item.No_Handphone?.toLowerCase() ?? '';
        return nama.contains(searchController.text.toLowerCase()) ||
            noHandphone.contains(searchController.text.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                    color: Colors.white,borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none
                          ),
                    ),
                  ),
                ),
                // Table Header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Row(
                    children: [
                      // Add headers for each column
                      Expanded(
                        flex: 1,
                        child: Center(child: Text('Nama')),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(child: Text('No Handphone')),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(child: Text('Kategori Pesan')),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(child: Text('Status Pesan')),
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
                            // Add data for each column
                            Expanded(
                              flex: 1,
                              child: ExpandableText(
                                item.Nama ?? '',
                                expandText: 'show more',
                                collapseText: 'show less',
                                maxLines: 2,
                                linkColor: Colors.blue,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: ExpandableText(
                                  item.No_Handphone ?? '',
                                  expandText: 'show more',
                                  collapseText: 'show less',
                                  maxLines: 2,
                                  linkColor: Colors.blue,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: ExpandableText(
                                  item.Kategori_Pesan ?? '',
                                  expandText: 'show more',
                                  collapseText: 'show less',
                                  maxLines: 2,
                                  linkColor: Colors.blue,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: ExpandableText(
                                  item.Status_Pesan ?? '',
                                  expandText: 'show more',
                                  collapseText: 'show less',
                                  maxLines: 2,
                                  linkColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        // Pagination Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  currentPage > 0 ? () => goToPage(currentPage - 1) : null,
            ),
            Text('Page ${currentPage + 1}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  (currentPage + 1) * rowsPerPage < widget.listPesan.length
                      ? () => goToPage(currentPage + 1)
                      : null,
            ),
          ],
        ),
      ],
    );
  }
}
