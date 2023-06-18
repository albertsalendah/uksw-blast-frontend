import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../navigation/sidenavigationbar.dart';

class FileReport extends StatefulWidget {
  const FileReport({super.key});

  @override
  State<FileReport> createState() => _FileReportState();
}

class _FileReportState extends State<FileReport> {
  List<String> files = [];
  String link = 'http://uksw-blast-api.marikhsalatiga.com/';
  //String link = 'http://localhost:8080/';

  @override
  void initState() {
    super.initState();
    fetchFileList();
  }

  Future<void> fetchFileList() async {
    final response = await http.get(Uri.parse('${link}files'));
    if (response.statusCode == 200) {
      final List<dynamic> fileList = json.decode(response.body);
      setState(() {
        files = fileList.cast<String>();
      });
    }
  }

  Future<void> downloadFile(String filename) async {
    final anchor = AnchorElement(
      href: '${link}download/$filename',
    )
      ..setAttribute('download', filename)
      ..click();
  }

  Future<void> deleteFile(String filename) async {
    final response = await http.delete(Uri.parse('${link}delete/$filename'));
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
    return Scaffold(
      appBar: AppBar(title: const Text('File Report')),
      drawer: SideNavigationBar(),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final filename = files[index];
          return ListTile(
            title: Text(filename),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () => downloadFile(filename),
                ),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => {
                      showDeleteAlertDialog(context, filename)
                    } //deleteFile(filename),
                    ),
              ],
            ),
          );
        },
      ),
    );
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
                deleteFile(filename);
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
