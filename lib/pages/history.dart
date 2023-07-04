import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:blast_whatsapp/models/history_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../navigation/sidenavigationbar.dart';
import '../screens/table_hisory_pesan.dart';
import '../utils/SessionManager.dart';
import '../utils/config.dart';
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
  Timer? _timer;

  void handleHistorySelection(String idPesan) {
    getlistpesan(idPesan);
  }

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

  Future<void> downloadFile(String idPesan) async {
    // ignore: unused_local_variable
    final anchor = AnchorElement(
      href: '${link}downloadhistorypesan/$idPesan',
    )
      ..setAttribute('download', idPesan)
      ..click();
  }

  void startSessionTimer() {
    _timer = Timer.periodic(Duration(minutes: Config().logoutDuration),
        (timer) async {
      final isSessionExpired = await SessionManager.isSessionExpired();
      if (isSessionExpired) {
        await SessionManager.logout();
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    startSessionTimer();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                      return Column(
                        children: [
                          const SizedBox(height: 8,),
                          Card(
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      handleHistorySelection(
                                          listHistory[index].id_pesan ?? '');
                                    },
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                                "Kategori Pesan : ${listHistory[index].Kategori_Pesan}"),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                          "Tanggal Kirim : ${listHistory[index].tanggal}"),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          downloadFile(
                                              listHistory[index].id_pesan ?? '');
                                        },
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
                                        showDeleteHirtoryAlertDialog(
                                            context,
                                            listHistory[index].id_pesan ?? '',
                                            listHistory[index].Kategori_Pesan ?? '');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8,),
                          const Divider(color: Colors.grey,height: 1,)
                        ],
                      );
                    }),
              ),
              const VerticalDivider(
                width: 20,
                thickness: 1,
                indent: 20,
                endIndent: 0,
                color: Colors.grey,
              ),
              Expanded(
                child: Visibility(
                    visible: listpesan.isNotEmpty,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: DataTablePesan(listPesan: listpesan)),
                      ],
                    )),
              )
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        drawer: SideNavigationBar(),
        body: const Center(child: Text("Belum Ada Histori Pesan")),
      );
    }
  }

  showDeleteHirtoryAlertDialog(
      BuildContext context, String id_pesan, String Kat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Hapus $Kat?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  deletelistpesan(id_pesan);
                  handleHistorySelection(id_pesan);
                });
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
