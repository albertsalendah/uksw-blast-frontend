import 'package:blast_whatsapp/models/history_models.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';

class DataTablePesan extends StatefulWidget {
  final List<history_models> listPesan;
  const DataTablePesan({required this.listPesan});

  @override
  _DataTablePesanState createState() => _DataTablePesanState();
}

class _DataTablePesanState extends State<DataTablePesan> {
  final int rowsPerPage = 20;
  int currentPage = 0;

  List<history_models> paginatedList = [];

  @override
  void initState() {
    super.initState();
    paginateList();
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
      paginateList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(10),
            child: const Row(
              children: [
                // Add headers for each column
                Expanded(
                  flex: 1,
                  child: Text('Nama'),
                ),
                Expanded(
                  flex: 1,
                  child: Text('No Handphone'),
                ),
                Expanded(
                  flex: 1,
                  child: Text('id_pesan'),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Kategori Pesan'),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Status Pesan'),
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
                      // Add data for each column
                      Expanded(
                        flex: 1,
                        child: ExpandableText(
                          item.Nama ?? '',
                          expandText: 'show more',
                          collapseText: 'show less',
                          //maxLines: 1,
                          linkColor: Colors.blue,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(item.No_Handphone ?? ''),
                      ),
                      Expanded(
                        flex: 1,
                        child: ExpandableText(
                          item.id_pesan ?? '',
                          expandText: 'show more',
                          collapseText: 'show less',
                          maxLines: 1,
                          linkColor: Colors.blue,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ExpandableText(
                          item.Kategori_Pesan ?? '',
                          expandText: 'show more',
                          collapseText: 'show less',
                          maxLines: 1,
                          linkColor: Colors.blue,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ExpandableText(
                          item.Status_Pesan ?? '',
                          expandText: 'show more',
                          collapseText: 'show less',
                          maxLines: 1,
                          linkColor: Colors.blue,
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
                onPressed:
                    currentPage > 0 ? () => goToPage(currentPage - 1) : null,
              ),
              Text('Page ${currentPage + 1}'),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed:
                    (currentPage + 1) * rowsPerPage < widget.listPesan.length
                        ? () => goToPage(currentPage + 1)
                        : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
