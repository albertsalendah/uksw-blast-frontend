import 'dart:async';
import 'dart:convert';
import 'package:blast_whatsapp/models/progdi_models.dart';
import 'package:blast_whatsapp/models/template_pesan.dart';
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
import '../screens/tabel_tamplate_pesan.dart';
import '../utils/SessionManager.dart';
import '../utils/config.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String link = Links().link;
  TextEditingController messageController = TextEditingController();
  TextEditingController kategoriPesan = TextEditingController();
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
  Timer? _timer;
  bool isLoading = false;
  String restotalNomor = '';

  @override
  void initState() {
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.listJob = handleJobs;
    startSessionTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // socketProvider = Provider.of<SocketProvider>(context, listen: false);
    // socketProvider.socket?.dispose();
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

  Future<void> checkTotalMahasiswa() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('${link}checktotalmahasiswa');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'tahun': selectedYear,
          'progdi': selectedKodeProgdi,
          'status_regis': selectedValue,
        },
      ),
    );
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        restotalNomor = jsonDecode(response.body)['response'].toString();
        print(jsonDecode(response.body)['response']);
      });
    } else {
      setState(() {
        isLoading = false;
        restotalNomor = '';
      });
      print('Check Data Failed: ${jsonDecode(response.body)['response']}');
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      List<PlatformFile> file = result.files;
      setState(() {
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

  Future<bool> tambahTemplatePesan(
      String kategoriPesan, String isiPesan) async {
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
      return true;
    } else {
      // Error adding data
      print('Failed to add data to MongoDB');
      return false;
    }
  }

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
        padding: const EdgeInsets.all(16.0),
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
                            Text("Pilih Excel File .xlsx | "),
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
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => deleteExcelFile(0),
                          )
                        ]),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
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
                            Text("Pilih File Untuk Dikirim | "),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      if (files.isNotEmpty)
                        Row(children: [
                          Text(files[0].name),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => deleteFile(0),
                          )
                        ])
                    ],
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
                  const SizedBox(
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
                          onPressed: () async {
                            if (kategoriPesan.text.isNotEmpty &&
                                messageController.text.isNotEmpty) {
                              if (await tambahTemplatePesan(
                                  kategoriPesan.text, messageController.text)) {
                                // ignore: use_build_context_synchronously
                                NOTIF_SCREEN.show(context, "Success",
                                    "Template Pesan Berhasil Disimpan");
                              } else {
                                // ignore: use_build_context_synchronously
                                NOTIF_SCREEN.show(context, "Failed",
                                    "Template Pesan Gagal Disimpan");
                              }
                            } else {
                              NOTIF_SCREEN.show(context, "Error",
                                  "Kategori Pesan dan Pesan Tidak Boleh Kosong");
                            }
                          },
                          icon: const Icon(Icons.add_comment,
                              color: Colors.grey)),
                      //const SizedBox(width: 8,),
                      IconButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return DataTableTemplatePesan(
                                    //daftar_template: daftar_template,
                                    kategoriPesanController: kategoriPesan,
                                    isiPesanController: messageController);
                              },
                            );
                          },
                          icon: const Icon(Icons.list, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  InputDecorator(
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    child: SizedBox(
                      height: 15,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          menuMaxHeight: 300,
                          value: selectedYear,
                          onChanged: (newValue) {
                            setState(() {
                              selectedYear = newValue!;
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
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownSearch<String>(
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
                            itemBuilder: (context, item, isSelected) =>
                                ListTile(
                              title: Column(
                                children: [
                                  Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Visibility(
                        visible: !isLoading,
                        replacement: const CircularProgressIndicator(),
                        child: IconButton(
                          onPressed: () async {
                            await checkTotalMahasiswa();
                            if(restotalNomor.isNotEmpty && !isLoading){
                              NOTIF_SCREEN.show(context, "Success", "Total Nomor Yang Ditemukan : $restotalNomor");
                            }else{
                              NOTIF_SCREEN.show(context, "Failed", "Gagal Mengambil Data Dari Server");
                            }
                          },
                          icon: const Icon(
                            Icons.numbers,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  InputDecorator(
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    child: SizedBox(
                      height: 15,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
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
                              child: Text('Belum Registrasi Ulang'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Diterima',
                              child: Text('Diterima (Sudah Registrasi Ulang)'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'All',
                              child: Text('All'),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    child: const Text('Send Request'),
                  ),
                  const SizedBox(
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
