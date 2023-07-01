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
    } else {
      print('File deletion failed: $filename');
    }
  }

  @override
  Widget build(BuildContext context) {
    if(files.isNotEmpty){
      return Scaffold(
      appBar: AppBar(title: const Text('Uploaded Excel File')),
      drawer: SideNavigationBar(),
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final filename = files[index];
                return ListTile(
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
                          onPressed: () =>
                              {showDeleteAlertDialog(context, filename)}),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    }else{
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