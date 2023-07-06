import 'dart:async';
import 'dart:convert';
import 'package:blast_whatsapp/models/progdi_models.dart';
import 'package:blast_whatsapp/models/template_pesan.dart';
import 'package:blast_whatsapp/screens/messageCard.dart';
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
import 'package:mime/mime.dart';

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
  String selectedNamaProgdi = '';
  List<String> listProgdi = [];
  List<Template_Pesan> daftar_template = [];
  Timer? _timer;
  bool isLoading = false;
  String restotalNomor = '';
  bool loadbtnsend = false;
  Uint8List? imagebytes;
  String displayMessage = '';

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
    setState(() {
      loadbtnsend = true;
    });
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
        String fieldName = 'daftar_no';
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

    if (responseString != '') {
      setState(() {
        loadbtnsend = false;
      });
    }

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
        String? mimeType = lookupMimeType(files[0].name);
        if (mimeType?.startsWith('image') == true) {
          imagebytes = files[0].bytes;
        } else {
          print("file bukan gambar");
        }
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
      imagebytes = null;
    });
  }

  Future<void> loadProgramData() async {
    String jsonData = await rootBundle.loadString("assets/list_progdi.json");
    List<dynamic> jsonList = json.decode(jsonData);

    List<ProgdiModels> dataList =
        jsonList.map((json) => ProgdiModels.fromJson(json)).toList();

    for (var element in dataList) {
      listProgdi.add(element.namaProgdi);
    }
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

  void templatePicked(String item){
    setState(() {
      displayMessage = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      loadProgramData();
      //if(messageController.text.isNotEmpty){}
    });
    final activeJobs = jobs.where((job) => job.status != 'completed').toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: SideNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Stack(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.6,
                  child: ListView(children: [
                    if (messageController.text.isNotEmpty)
                      MessageCard(
                        message: displayMessage,
                        imagebytes: imagebytes,
                      )
                  ]),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (listNohp.isNotEmpty)
                          Expanded(
                            child: Row(children: [
                              Card(
                                color: const Color.fromRGBO(0, 167, 131, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(150),
                                ),
                                elevation: 3,
                                child: const IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.contact_page,
                                      color: Colors.white,
                                    )),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                listNohp[0].name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.grey),
                                onPressed: () => deleteExcelFile(0),
                              )
                            ]),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        if (files.isNotEmpty)
                          Expanded(
                            child: Row(children: [
                              Card(
                                color: const Color.fromRGBO(0, 167, 131, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(150),
                                ),
                                elevation: 3,
                                child: const IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    )),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                files[0].name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.grey),
                                onPressed: () => deleteFile(0),
                              )
                            ]),
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Card(
                            color: const Color.fromRGBO(0, 167, 131, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(150),
                            ),
                            elevation: 3,
                            child: IconButton(
                                onPressed: () {
                                  showListProgdi(context);
                                },
                                icon: const Icon(
                                  Icons.list,
                                  color: Colors.white,
                                ))),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(selectedNamaProgdi.isNotEmpty
                            ? '$selectedNamaProgdi ($selectedKodeProgdi)'
                            : 'Daftar Program Studi')
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Card(
                          color: const Color.fromRGBO(0, 167, 131, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                          ),
                          elevation: 3,
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.date_range,
                              size: 24,
                              color: Colors.white,
                            ),
                            itemBuilder: (BuildContext context) {
                              return List<PopupMenuEntry<String>>.generate(
                                86, // Number of years from 2015 to 2100
                                (index) {
                                  final startYear = 2012 + index;
                                  final endYear = 2013 + index;
                                  final yearRange = '$startYear-$endYear';
                                  return PopupMenuItem<String>(
                                    value: yearRange,
                                    child: Text(yearRange),
                                  );
                                },
                              );
                            },
                            initialValue: selectedYear,
                            onSelected: (String? newValue) {
                              setState(() {
                                selectedYear = newValue!;
                              });
                            },
                          ),
                        ),
                        const Text("Tahun Ajaran "),
                        Text(selectedYear)
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Card(
                          color: const Color.fromRGBO(0, 167, 131, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                          ),
                          elevation: 3,
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.list,
                              color: Colors.white,
                              size: 24,
                            ),
                            onSelected: (value) {
                              setState(() {
                                selectedValue =
                                    value; // Update the selected value
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'Belum',
                                child: Text('Belum Registrasi Ulang'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Diterima',
                                child:
                                    Text('Diterima (Sudah Registrasi Ulang)'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'All',
                                child: Text(
                                    'All (Diterima & Belum Registrasi Ulang)'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          selectedValue == 'All'
                              ? 'All (Diterima & Belum Registrasi Ulang)'
                              : selectedValue == 'Belum'
                                  ? 'Belum Registrasi Ulang'
                                  : selectedValue == 'Diterima'
                                      ? 'Diterima (Sudah Registrasi Ulang)'
                                      : 'Status Registrasi',
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Visibility(
                          visible: !isLoading,
                          replacement: const CircularProgressIndicator(),
                          child: Card(
                            color: const Color.fromRGBO(0, 167, 131, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(150),
                            ),
                            elevation: 3,
                            child: IconButton(
                              onPressed: () async {
                                if (selectedKodeProgdi.isNotEmpty) {
                                  await checkTotalMahasiswa();
                                  if (restotalNomor.isNotEmpty && !isLoading) {
                                    // ignore: use_build_context_synchronously
                                    NOTIF_SCREEN.show(context, "Success",
                                        "Total Nomor Yang Ditemukan : $restotalNomor");
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    NOTIF_SCREEN.show(context, "Failed",
                                        "Gagal Mengambil Data Dari Server");
                                  }
                                } else {
                                  NOTIF_SCREEN.show(context, "Error",
                                      "Silahkan Pilih Progdi");
                                }
                              },
                              icon: const Icon(
                                Icons.numbers,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text("Cek Total Nomor Hp Di API")
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    // IntrinsicWidth(
                    //   child: TextField(
                    //     maxLines: 1,
                    //     controller: kategoriPesan,
                    //   ),
                    // ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Kategori Pesan'),
                      maxLines: 1,
                      controller: kategoriPesan,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  displayMessage = value;
                                });
                              },
                              minLines: 1,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              controller: messageController,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.attachment),
                                    onPressed: () async {
                                      await pickFiles();
                                    },
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                  labelText: 'Pesan'),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                await daftarNomor();
                              },
                              icon: const Icon(Icons.contact_page,
                                  color: Colors.grey)),
                          IconButton(
                              onPressed: () async {
                                if (kategoriPesan.text.isNotEmpty &&
                                    messageController.text.isNotEmpty) {
                                  if (await tambahTemplatePesan(
                                      kategoriPesan.text,
                                      messageController.text)) {
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
                            icon: const Icon(Icons.list, color: Colors.grey),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return DataTableTemplatePesan(
                                      kategoriPesanController: kategoriPesan,
                                      isiPesanController: messageController,templatepick: templatePicked);
                                },
                              );
                            },
                          ),
                          Visibility(
                            visible: !loadbtnsend,
                            replacement: const CircularProgressIndicator(),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.grey),
                              onPressed: () async {
                                if (messageController.text.isNotEmpty &&
                                    selectedKodeProgdi.isNotEmpty &&
                                    kategoriPesan.text.isNotEmpty) {
                                  await sendPostRequest();
                                } else {
                                  popUp(context,
                                      "Message & Progdi Tidak Boleh Kosong");
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ]),
            ),
            Visibility(
              visible: activeJobs.isNotEmpty,
              child: const VerticalDivider(
                width: 20,
                thickness: 1,
                indent: 20,
                endIndent: 0,
                color: Colors.grey,
              ),
            ),
            //--------------------PROGRESS-----------------------------------------------------------
            Visibility(
              visible: activeJobs.isNotEmpty,
              child: Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: activeJobs.length,
                        itemBuilder: (context, index) {
                          final job = activeJobs[index];
                          return Column(
                            children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Card(
                                elevation: 3,
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Mengirim Pesan Ke Progdi : ${job.sendto}'),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Progress: ${job.progress}%'),
                                      Text('Status: ${job.status}'),
                                      Text(job.message)
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
        ),
      ),
    );
  }

  showListProgdi(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daftar Program Studi'),
          content: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width / 2,
            child: DropdownSearch<String>(
              items: listProgdi, //List.generate(50, (i) => i),
              onChanged: (value) {
                setState(() {
                  programDataList.forEach((element) {
                    if (element.namaProgdi == value) {
                      selectedKodeProgdi = element.kodeProgdi;
                      selectedNamaProgdi = element.namaProgdi;
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
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
