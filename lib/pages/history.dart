import 'dart:convert';

import 'package:blast_whatsapp/models/history_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../navigation/sidenavigationbar.dart';


class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<history_models> listHistory = [];
  String? sortColumn;
  bool isAscending = true;
  String link = 'http://uksw-blast-api.marikhsalatiga.com/';
  //String link = 'http://localhost:8080/';
  //String link = 'http://192.168.137.1:8080/';
  Future<void> fetchData() async {
    try {
      final historyResponse = await http
          .get(Uri.parse('${link}history'));
      if (historyResponse.statusCode == 200) {
        setState(() {
          List<dynamic> data = jsonDecode(historyResponse.body);
          listHistory =
              data.map((json) => history_models.fromJson(json)).toList();
        });
      } else {
        print('Failed to send data. Error: ${historyResponse.statusCode}');
        fetchData();
      }
    } catch (e) {
      print(e);
      fetchData();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void sortData(String column) {
    setState(() {
      if (sortColumn == column) {
        // Reverse the sort order if the same column is selected again
        isAscending = !isAscending;
      } else {
        // Set the new sort column and order
        sortColumn = column;
        isAscending = true;
      }

      // Sort the list based on the selected column and order
      switch (sortColumn) {
        case 'tanggal':
          listHistory
              .sort((a, b) => (a.tanggal ?? '').compareTo(b.tanggal ?? ''));
          break;
        case 'tahun_ajaran':
          listHistory.sort(
              (a, b) => (a.tahun_ajaran ?? '').compareTo(b.tahun_ajaran ?? ''));
          break;
        case 'progdi':
          listHistory
              .sort((a, b) => (a.progdi ?? '').compareTo(b.progdi ?? ''));
          break;
        case 'status_registrasi':
          listHistory.sort((a, b) =>
              (a.status_registrasi ?? '').compareTo(b.status_registrasi ?? ''));
          break;
      }

      // Reverse the list order if it's in descending order
      if (!isAscending) {
        listHistory = listHistory.reversed.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      drawer: SideNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: fetchData,
          child: ListView(
            children: [
              DataTable(
                columns: [
                  DataColumn(
                    label: Text('Tanggal', maxLines: 1),
                    onSort: (columnIndex, _) => sortData('tanggal'),
                  ),
                  DataColumn(
                    label: Text('No Pendaftaran', maxLines: 1),
                    onSort: (columnIndex, _) => sortData('no_pendaftaran'),
                  ),
                  DataColumn(
                    label: Text('Nama', maxLines: 1),
                    onSort: (columnIndex, _) => sortData('nama'),
                  ),
                  DataColumn(
                    label: Text('Tahun Ajaran', maxLines: 1),
                    onSort: (columnIndex, _) => sortData('tahun_ajaran'),
                  ),
                  DataColumn(
                    label: Text('Progdi', maxLines: 1),
                    onSort: (columnIndex, _) => sortData('progdi'),
                  ),
                  DataColumn(
                    label: Text('Pesan', maxLines: 1),
                    onSort: (columnIndex, _) => sortData('pesan'),
                  ),
                  DataColumn(
                    label: Text('Status Registrasi', maxLines: 1),
                    onSort: (columnIndex, _) => sortData('status_registrasi'),
                  ),
                ],
                rows: listHistory
                    .map(
                      (history) => DataRow(
                        cells: [
                          DataCell(Text(
                            history.tanggal ?? '',
                            maxLines: 1,
                          )),
                          DataCell(
                              Text(history.no_pendaftaran ?? '', maxLines: 1)),
                          DataCell(Text(history.nama ?? '', maxLines: 1)),
                          DataCell(
                              Text(history.tahun_ajaran ?? '', maxLines: 1)),
                          DataCell(Text(history.progdi ?? '', maxLines: 1)),
                          DataCell(Text(history.pesan ?? '', maxLines: 1)),
                          DataCell(Text(history.status_registrasi ?? '',
                              maxLines: 1)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchData,
        child: Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
