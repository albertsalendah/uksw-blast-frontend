import 'dart:convert';

import 'package:blast_whatsapp/models/history_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../navigation/sidenavigationbar.dart';
import '../screens/table_hisory_pesan.dart';
import '../utils/link.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<history_models> listHistory = [];
  String? sortColumn;
  bool isAscending = true;
  String link = Links().link;
  List<history_models> listpesan = [];

  Future<void> getlistpesan(String idPesan) async {
    var request =
        http.Request('GET', Uri.parse('${link}getlistpesan/$idPesan'));
    request.body = '''''';

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      List<dynamic> parsedData = json.decode(responseString);
      setState(() {
        listpesan =
            parsedData.map((item) => history_models.fromJson(item)).toList();
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> deletelistpesan(String idPesan) async {
    var request =
        http.Request('POST', Uri.parse('${link}deletelistpesan/$idPesan'));
    request.body = '''''';

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      dynamic parsedData = json.decode(responseString);
      print(parsedData);
      fetchData();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> fetchData() async {
    try {
      final historyResponse = await http.get(Uri.parse('${link}history'));
      if (historyResponse.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(historyResponse.body);
        setState(() {
          listHistory =
              jsonData.map((item) => history_models.fromJson(item)).toList();
        });
      } else {
        print('Failed to send data. Error: ${historyResponse.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (listHistory.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('History')),
        drawer: SideNavigationBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: listHistory.length,
                    itemBuilder: (ctx, index) {
                      if (index >= listHistory.length) {
                        return null; // Return null for indices out of range
                      }
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Kategori Pesan : ${listHistory[index].Kategori_Pesan}"),
                                    Text(
                                        "Tanggal Kirim : ${listHistory[index].tanggal}"),
                                    Text(
                                        "ID Pesan : ${listHistory[index].id_pesan}"),
                                    const Divider(
                                      color: Colors.grey,
                                      height: 1,
                                    )
                                  ],
                                ),
                                onTap: () async {
                                  await getlistpesan(
                                      listHistory[index].id_pesan ?? '');
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.grey,
                                      )),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.grey),
                                    onPressed: () {
                                      deletelistpesan(
                                          listHistory[index].id_pesan ?? '');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              Expanded(
                child: Visibility(
                  visible: listpesan.isNotEmpty,
                  child: listpesan.length > 1
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                              child: DataTablePesan(listPesan: listpesan),
                            ),
                        ],
                      )
                      : DataTablePesan(listPesan: listpesan),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('History')),
        drawer: SideNavigationBar(),
        body: Center(child: Text("Belum Ada Histori Pesan")),
      );
    }
  }
}
