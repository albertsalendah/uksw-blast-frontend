import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../navigation/sidenavigationbar.dart';
import '../utils/SessionManager.dart';
import '../utils/config.dart';
import '../utils/link.dart';

class ExtraData extends StatefulWidget {
  const ExtraData({super.key});

  @override
  State<ExtraData> createState() => _ExtraDataState();
}

class _ExtraDataState extends State<ExtraData> {
  List<String> filesSisa = [];
  final String link = Links().link;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchFileListSisa();
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

  Future<void> fetchFileListSisa() async {
    final response = await http.get(Uri.parse('${link}filesSisaData'));
    if (response.statusCode == 200) {
      final List<dynamic> fileList = json.decode(response.body);
      setState(() {
        filesSisa = fileList.cast<String>();
      });
    }
  }

  Future<void> downloadFileSisaData(String filename) async {
    // ignore: unused_local_variable
    final anchor = AnchorElement(
      href: '${link}downloadfileSisaData/$filename',
    )
      ..setAttribute('download', filename)
      ..click();
  }

  Future<void> deleteFileSisaData(String filename) async {
    final response =
        await http.delete(Uri.parse('${link}deletefileSisaData/$filename'));
    if (response.statusCode == 200) {
      print('File deleted: $filename');
      // Refresh the file list
      fetchFileListSisa();
    } else {
      print('File deletion failed: $filename');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (filesSisa.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('File Extra Data')),
        drawer: SideNavigationBar(),
        body: Row(
          children: [
            Flexible(
              flex: 1,
              child: ListView.builder(
                itemCount: filesSisa.length,
                itemBuilder: (context, index) {
                  final filename = filesSisa[index];
                  return ListTile(
                    title: Text(filename),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => downloadFileSisaData(filename),
                        ),
                        IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => {
                                  showDeleteSisaDataAlertDialog(
                                      context, filename)
                                }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('File Extra Data')),
        drawer: SideNavigationBar(),
        body: const Center(child: Text("Belum Ada File")),
      );
    }
  }

  showDeleteSisaDataAlertDialog(BuildContext context, String filename) {
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
                  deleteFileSisaData(filename);
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
