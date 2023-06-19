import 'dart:async';
import 'dart:convert';
import 'package:blast_whatsapp/models/progdi_models.dart';
import 'package:blast_whatsapp/models/template_pesan.dart';
import 'package:blast_whatsapp/screens/list_templates.dart';
import 'package:blast_whatsapp/screens/notif_screen.dart';
import 'package:blast_whatsapp/socket/socket_provider.dart';
import 'package:blast_whatsapp/utils/link.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../navigation/sidenavigationbar.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String link = Links().link;
  TextEditingController messageController = TextEditingController();
  TextEditingController kategoriPesan = TextEditingController();
  final TextEditingController _kategoriPesanController =
      TextEditingController();
  final TextEditingController _isiPesanController = TextEditingController();
  List<PlatformFile> listNohp = [];
  List<PlatformFile> files = [];
  String selectedValue = 'All';
  String selectedYear = '2023-2024';
  List<Job> jobs = [];
  late SocketProvider socketProvider;
  List<ProgdiModels> programDataList = [];
  String selectedKodeProgdi = '';
  List<String> listProgdi = [];
  List<Template_Pesan> daftar_template = [];

  @override
  void initState() {
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.listJob = handleJobs;
    //loadProgramData();
    super.initState();
  }

  @override
  void dispose() {
    //socketProvider = Provider.of<SocketProvider>(context, listen: false);
    //socketProvider.socket?.disconnect();
    super.dispose();
  }

  void handleJobs(List<Job> job) {
    setState(() {
      jobs = job;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketProvider = Provider.of<SocketProvider>(context);
  }

  Future<void> sendPostRequest() async {
    var url = '${link}send-message';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['message'] = messageController.text;
    request.fields['kategori_pesan'] = kategoriPesan.text;
    request.fields['tahun'] = selectedYear;
    request.fields['progdi'] = selectedKodeProgdi;
    request.fields['status_regis'] = selectedValue;

    // Attach files, if any
    if (files.isNotEmpty) {
      for (var file in files) {
        String fieldName =
            'file_dikirim'; // Adjust field name as per your server code
        String fileName = file.name;
        var fileBytes = file.bytes;
        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            fileBytes!,
            filename: fileName,
          ),
        );
      }
    }

    // Attach files, if any
    if (listNohp.isNotEmpty) {
      for (var file in listNohp) {
        String fieldName =
            'daftar_no'; // Adjust field name as per your server code
        String fileName = file.name;
        var fileBytes = file.bytes;
        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            fileBytes!,
            filename: fileName,
          ),
        );
      }
    }

    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseString);
    final jobId = jsonResponse['jobId'];

    Job? existingJob;
    for (final job in jobs) {
      if (job.id == jobId) {
        existingJob = job;
        break;
      }
    }

    if (existingJob != null) {
      return; // Skip adding the duplicate job
    }

    // Add the new job to the list
    jobs.add(Job(id: jobId));
  }

  Future<void> pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      //List<File> pickedFiles = result.paths.map((path) => File(path!)).toList();
      List<PlatformFile> file = result.files;
      setState(() {
        //files = pickedFiles;
        files = file;
      });
    }
  }

  Future<void> daftarNomor() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (result != null) {
      List<PlatformFile> file = result.files;
      setState(() {
        listNohp = file;
      });
    }
  }

  void deleteExcelFile(int index) {
    setState(() {
      listNohp.removeAt(index);
    });
  }

  void deleteFile(int index) {
    setState(() {
      files.removeAt(index);
    });
  }

  Future<void> loadProgramData() async {
    String jsonData = await rootBundle.loadString("assets/list_progdi.json");
    List<dynamic> jsonList = json.decode(jsonData);

    List<ProgdiModels> dataList =
        jsonList.map((json) => ProgdiModels.fromJson(json)).toList();

    dataList.forEach((element) {
      listProgdi.add(element.namaProgdi);
    });
    programDataList = dataList;
  }

  Future<void> fetchdaftarTemplate() async {
    final url = '${link}daftar_template';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      final List<Template_Pesan> fetchedMessages = responseData
          .map((daftar_template) => Template_Pesan(
                id: daftar_template['_id'],
                kategoriPesan: daftar_template['kategori_pesan'],
                isiPesan: daftar_template['isi_pesan'],
              ))
          .toList();
      setState(() {
        daftar_template = fetchedMessages;
      });
    } else {
      // Error fetching data
      print('Failed to fetch messages from MongoDB');
    }
  }

  void tambahTemplatePesan(String kategoriPesan, String isiPesan) async {
    final url = '${link}tambah_template_pesan';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'kategori_pesan': kategoriPesan,
        'isi_pesan': isiPesan,
      },
    );

    if (response.statusCode == 200) {
      // Data added successfully
      print('Data added to MongoDB');
    } else {
      // Error adding data
      print('Failed to add data to MongoDB');
    }
  }

  // Future<void> deleteTemplatePesan(String messageId) async {
  //   final url = '${link}delete_template_pesan/$messageId';

  //   final response = await http.delete(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     // Data deleted successfully
  //     print('Data deleted from MongoDB');
  //     fetchdaftarTemplate(); // Refresh the message list
  //   } else {
  //     // Error deleting data
  //     print('Failed to delete data from MongoDB');
  //   }
  // }

  // Future<void> _updateTemplatePesan(String id) async {
  //   final String kategoriPesan = _kategoriPesanController.text;
  //   final String isiPesan = _isiPesanController.text;

  //   // Send the update request to the backend API
  //   final response = await http.put(
  //     Uri.parse('${link}edit_template_pesan/${id}'),
  //     body: {
  //       'kategori_pesan': kategoriPesan,
  //       'isi_pesan': isiPesan,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     // Data updated successfully
  //     // You can handle the success case based on your requirements
  //     Navigator.of(context).pop();
  //   } else {
  //     // Update failed
  //     // You can handle the error case based on your requirements
  //     print('Update failed: ${response.statusCode}');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    setState(() {
      loadProgramData();
    });
    final activeJobs = jobs.where((job) => job.status != 'completed').toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: ListView(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          await daftarNomor();
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.contact_page, color: Colors.grey),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Pilih Excel File .xlsx : "),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      if (listNohp.isNotEmpty)
                        Row(children: [
                          Text(listNohp[0].name),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => deleteExcelFile(0),
                          )
                        ]),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  InkWell(
                    onTap: () async {
                      await pickFiles();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image, color: Colors.grey),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Pilih File Untuk Dikirim"),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    maxLines: 1,
                    controller: kategoriPesan,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                        contentPadding: EdgeInsets.all(10),
                        labelText: 'Kategori Pesan'),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          controller: messageController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                              contentPadding: EdgeInsets.all(10),
                              labelText: 'Pesan'),
                        ),
                      ),
                      //const SizedBox(width: 8,),
                      IconButton(
                          onPressed: () {
                            if (kategoriPesan.text.isNotEmpty &&
                                messageController.text.isNotEmpty) {
                              tambahTemplatePesan(
                                  kategoriPesan.text, messageController.text);

                              NOTIF_SCREEN.show(context, "Success",
                                  "Template Pesan Berhasil Disimpan");
                            } else {
                              NOTIF_SCREEN.show(context, "Error",
                                  "Kategori Pesan dan Pesan Tidak Boleh Kosong");
                            }
                          },
                          icon: Icon(Icons.add_comment, color: Colors.grey)),
                      //const SizedBox(width: 8,),
                      IconButton(
                          onPressed: () async {
                            await fetchdaftarTemplate();
                            setState(() {
                              List_Templates().showdaftarTemplateAlertDialog(
                                  context,
                                  kategoriPesan,
                                  messageController,
                                  daftar_template);
                            });
                          },
                          icon: const Icon(Icons.list, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    menuMaxHeight: 300,
                    value: selectedYear,
                    onChanged: (newValue) {
                      setState(() {
                        selectedYear = newValue!;
                        print(selectedYear);
                      });
                    },
                    items: List<DropdownMenuItem<String>>.generate(
                      86, // Number of years from 2015 to 2100
                      (index) {
                        final startYear = 2012 + index;
                        final endYear = 2013 + index;
                        final yearRange = '$startYear-$endYear';
                        return DropdownMenuItem<String>(
                          value: yearRange,
                          child: Text(yearRange),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  DropdownSearch<String>(
                    items: listProgdi, //List.generate(50, (i) => i),
                    onChanged: (value) {
                      setState(() {
                        programDataList.forEach((element) {
                          if (element.namaProgdi == value) {
                            selectedKodeProgdi = element.kodeProgdi;
                          }
                        });
                      });
                    },
                    dropdownBuilder: (context, selectedItem) => Text(
                        (selectedKodeProgdi.isNotEmpty)
                            ? selectedItem ?? "Progdi"
                            : "Progdi"),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      title: const Text('Daftar Progdi'),
                      itemBuilder: (context, item, isSelected) => ListTile(
                        title: Column(
                          children: [
                            Text(
                              item,
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedValue,
                    onChanged: (newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Belum',
                        child: Text('Belum'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Diterima',
                        child: Text('Diterima'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'All',
                        child: Text('All'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (messageController.text.isNotEmpty &&
                          selectedKodeProgdi.isNotEmpty &&
                          kategoriPesan.text.isNotEmpty) {
                        await sendPostRequest();
                      } else {
                        print("text kosong");
                        popUp(context, "Message & Progdi Tidak Boleh Kosong");
                      }
                      setState(() {
                        messageController.text = '';
                        selectedYear = '2023-2024';
                        selectedValue = 'All';
                        selectedKodeProgdi = '';
                        kategoriPesan.text = '';
                        files = [];
                        listNohp = [];
                      });
                    },
                    child: Text('Send Request'),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text('Selected Files: ${files.length}'),
                  if (files.isNotEmpty)
                    Column(
                      children: files
                          .asMap()
                          .entries
                          .map(
                            (entry) => ListTile(
                              title: Text(entry.value.name),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => deleteFile(entry.key),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
//--------------------PROGRESS-----------------------------------------------------------
            Visibility(
              visible: activeJobs.isNotEmpty,
              child: Flexible(
                flex: 1,
                child: Column(
                  children: [
                    const Center(
                      child: Text("Jangan Direfresh!!!"),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: activeJobs.length,
                        itemBuilder: (context, index) {
                          final job = activeJobs[index];
                          return ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Mengirim Pesan Ke Progdi : ${job.sendto}'),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Progress: ${job.progress}%'),
                                Text('Status: ${job.status}'),
                                Text(job.message)
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // showdaftarTemplateAlertDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Daftar Template Pesan'),
  //         content: SizedBox(
  //           width: double.maxFinite,
  //           child: ListView.builder(
  //             itemCount: daftar_template.length,
  //             itemBuilder: (ctx, index) => ListTile(
  //               title: InkWell(
  //                 child: Text(daftar_template[index].kategoriPesan),
  //                 onTap: () {
  //                   kategoriPesan.text = daftar_template[index].kategoriPesan;
  //                   messageController.text = daftar_template[index].isiPesan;
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               subtitle: InkWell(
  //                 child: Text(daftar_template[index].isiPesan),
  //                 onTap: () {
  //                   kategoriPesan.text = daftar_template[index].kategoriPesan;
  //                   messageController.text = daftar_template[index].isiPesan;
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               trailing: SizedBox(
  //                 width: 100,
  //                 child: Row(
  //                   children: [
  //                     IconButton(
  //                         onPressed: () {
  //                           final updatedItem = daftar_template[index];
  //                           _showUpdateDialog(updatedItem);
  //                         },
  //                         icon: const Icon(Icons.edit)),
  //                     const SizedBox(
  //                       width: 8,
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.delete),
  //                       onPressed: () async {
  //                         await deleteTemplatePesan(daftar_template[index].id);
  //                         Navigator.of(context).pop();
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Kembali'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showUpdateDialog(Template_Pesan currentItem) {
  //   _kategoriPesanController.text = currentItem.kategoriPesan;
  //   _isiPesanController.text = currentItem.isiPesan;
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Update Item'),
  //         content: SizedBox(
  //           width: double.maxFinite,
  //           child: Column(
  //             children: [
  //               TextField(
  //                 controller: _kategoriPesanController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Kategori Pesan',
  //                   border: OutlineInputBorder(
  //                     borderSide: BorderSide(),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 16,
  //               ),
  //               TextField(
  //                 minLines: 1,
  //                 keyboardType: TextInputType.multiline,
  //                 maxLines: null,
  //                 textInputAction: TextInputAction.newline,
  //                 controller: _isiPesanController,
  //                 decoration: const InputDecoration(
  //                     border: OutlineInputBorder(
  //                       borderSide: BorderSide(),
  //                     ),
  //                     contentPadding: EdgeInsets.all(10),
  //                     labelText: 'Isi Pesan'),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 _updateTemplatePesan(currentItem.id);
  //                 fetchdaftarTemplate();
  //               });
  //               Navigator.of(context).pop();
  //               setState(() {
  //                 showdaftarTemplateAlertDialog(context);
  //               });
  //             },
  //             child: Text('Save'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}

void popUp(BuildContext context, String text) {
  AwesomeDialog(
    context: context,
    showCloseIcon: true,
    closeIcon: const Icon(
      Icons.close_rounded,
    ),
    animType: AnimType.scale,
    dialogType: DialogType.error,
    title: 'ERROR',
    desc: text,
  ).show();
}
