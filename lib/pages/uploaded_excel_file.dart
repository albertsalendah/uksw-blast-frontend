import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../navigation/sidenavigationbar.dart';
import '../utils/SessionManager.dart';
import '../utils/config.dart';
import '../utils/link.dart';

class UplodaedExcelFileList extends StatefulWidget {
  const UplodaedExcelFileList({super.key});

  @override
  State<UplodaedExcelFileList> createState() => _UplodaedExcelFileListState();
}

class _UplodaedExcelFileListState extends State<UplodaedExcelFileList> {
  List<String> files = [];
  List<String> filesSisa = [];
  final String link = Links().link;
  Timer? _timer;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFileList();
    startSessionTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Future<void> fetchFileList() async {
    final response = await http.get(Uri.parse('${link}uploadedfiles'));
    if (response.statusCode == 200) {
      final List<dynamic> fileList = json.decode(response.body);
      setState(() {
        files = fileList.cast<String>();
      });
    }
  }

  Future<void> downloadFile(String filename) async {
    // ignore: unused_local_variable
    final anchor = AnchorElement(
      href: '${link}downloaduploadedfile/$filename',
    )
      ..setAttribute('download', filename)
      ..click();
  }

  Future<void> deleteFile(String filename) async {
    final response =
        await http.delete(Uri.parse('${link}deleteuploadedfile/$filename'));
    if (response.statusCode == 200) {
      print('File deleted: $filename');
      // Refresh the file list
      fetchFileList();
      searchController.text = '';
    } else {
      print('File deletion failed: $filename');
    }
  }

  List<String> get filteredList {
    if (searchController.text.isEmpty) {
      return files;
    } else {
      return files.where((item) {
        final nama = item.toLowerCase();
        return nama.contains(searchController.text.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (files.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Uploaded Excel File')),
        drawer: SideNavigationBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
              Flexible(
                flex: 1,
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final filename = filteredList[index];
                    return Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Card(
                          elevation: 3,
                          child: ListTile(
                            title: Text(filename),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () => downloadFile(filename),
                                ),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => {
                                          showDeleteAlertDialog(
                                              context, filename)
                                        }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 1,
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Uploaded Excel File')),
        drawer: SideNavigationBar(),
        body: const Center(child: Text("Belum Ada File")),
      );
    }
  }

  showDeleteAlertDialog(BuildContext context, String filename) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Hapus $filename?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  deleteFile(filename);
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
