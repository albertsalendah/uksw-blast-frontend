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
  List<String> listHistory = [];
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

  Future<void> fetchData() async {
    try {
      final historyResponse = await http.get(Uri.parse('${link}history'));
      if (historyResponse.statusCode == 200) {
        setState(() {
          List<dynamic> data = jsonDecode(historyResponse.body);
          listHistory = List<String>.from(data);
        });
      } else {
        print('Failed to send data. Error: ${historyResponse.statusCode}');
        //fetchData();
      }
    } catch (e) {
      print(e);
      //fetchData();
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      drawer: SideNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 1,
              child: RefreshIndicator(
                  onRefresh: fetchData,
                  child: ListView.builder(
                      itemCount: listHistory.length,
                      itemBuilder: (ctx, index) {
                        if (index >= listHistory.length) {
                          return null; // Return null for indices out of range
                        }
                        return ListTile(
                          title: InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listHistory[index]),
                              ],
                            ),
                            onTap: () async {
                              await getlistpesan(listHistory[index]);
                              setState(() {});
                            },
                          ),
                        );
                      })),
            ),
            Flexible(
              flex: 2,
              child: Visibility(
                visible: listpesan.isNotEmpty,
                child: listpesan.length > 1
                    ? SingleChildScrollView(
                        child: DataTablePesan(listPesan: listpesan),
                      )
                    : DataTablePesan(listPesan: listpesan),
              ),
            )
          ],
        ),
      ),
    );
  }
}
