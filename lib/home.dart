import 'dart:convert';

import 'package:blast_whatsapp/socket/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:provider/provider.dart';
import 'navigation/sidenavigationbar.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController messageController = TextEditingController();
  TextEditingController tahunController = TextEditingController();
  TextEditingController progdiController = TextEditingController();
  //List<File> files = [];
  List<PlatformFile> files = [];
  String selectedValue = 'All';
  String selectedYear = '2023-2024';
  List<Job> jobs = [];
  late SocketProvider socketProvider;

  @override
  void initState() {
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.listJob = handleJobs;
    super.initState();
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
    var url = 'http://uksw-blast-api.marikhsalatiga.com/send-message';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['message'] = messageController.text;
    request.fields['tahun'] = selectedYear; //tahunController.text;
    request.fields['progdi'] = progdiController.text;
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

  void deleteFile(int index) {
    setState(() {
      files.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  TextField(
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    controller: messageController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 20),
                        labelText: 'Message'),
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
                  TextField(
                    maxLines: 1,
                    controller: progdiController,
                    decoration: InputDecoration(labelText: 'Progdi'),
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
                          progdiController.text.isNotEmpty) {
                        await sendPostRequest();
                      } else {
                        print("text kosong");
                        popUp(context, "Message & Progdi Tidak Boleh Kosong");
                      }
                      setState(() {
                        messageController.text = '';
                        selectedYear = '2023-2024';
                        progdiController.text = '';
                        selectedValue = 'All';
                        files = [];
                      });
                    },
                    child: Text('Send Request'),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await pickFiles();
                    },
                    child: Text('Select Files'),
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
                child: ListView.builder(
                  itemCount: activeJobs.length,
                  itemBuilder: (context, index) {
                    final job = activeJobs[index];
                    return ListTile(
                      title: Text('Mengirim Pesan Ke Progdi : ${job.sendto}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progress: ${job.progress}%'),
                          Text('Status: ${job.status}'),
                        ],
                      ),
                    );
                  },
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