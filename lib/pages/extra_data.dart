// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../navigation/sidenavigationbar.dart';
import '../screens/notif_screen.dart';
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
  TextEditingController searchController = TextEditingController();

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
    }else{
      NOTIF_SCREEN().popUpError(context, MediaQuery.of(context).size.width,
          "Gagal Mengambil Data Dari Database");
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
      // Refresh the file list
      fetchFileListSisa();
      searchController.text = '';
      NOTIF_SCREEN().popUpSuccess(context,MediaQuery.of(context).size.width,"Berhasil Menghapus File $filename Dari Server");
    } else {
      NOTIF_SCREEN().popUpSuccess(
          context,
          MediaQuery.of(context).size.width,
          "Gagal Menghapus File $filename Dari Server");
    }
  }

  List<String> get filteredList {
    if (searchController.text.isEmpty) {
      return filesSisa;
    } else {
      return filesSisa.where((item) {
        final nama = item.toLowerCase();
        return nama.contains(searchController.text.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (filesSisa.isNotEmpty) {
      return Stack(
        children: [
          Image.asset("assets/whatsapp_Back.png",height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,fit: BoxFit.cover),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text('File Extra Data')),
            drawer: const SideNavigationBar(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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
                          border: InputBorder.none,
                        ),
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
                              child: ListTile(
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
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Image.asset("assets/whatsapp_Back.png",height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,fit: BoxFit.cover),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text('File Extra Data')),
            drawer: const SideNavigationBar(),
            body: const Center(child: Text("Belum Ada File")),
          ),
        ],
      );
    }
  }

  showDeleteSisaDataAlertDialog(BuildContext context, String filename) {
    AwesomeDialog(
      width: MediaQuery.of(context).size.width / 3,
      context: context,
      showCloseIcon: true,
      closeIcon: const Icon(
        Icons.close_rounded,
      ),
      animType: AnimType.scale,
      dialogType: DialogType.question,
      title: 'Delete',
      desc: "Hapus File $filename ?",
      btnOkOnPress: () {
        deleteFileSisaData(filename);
      },
      btnCancelOnPress: () {},
    ).show();
  }
}
