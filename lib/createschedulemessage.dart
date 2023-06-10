
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CreateScheduleMessage extends StatefulWidget {
  const CreateScheduleMessage({super.key});

  @override
  State<CreateScheduleMessage> createState() => _CreateScheduleMessageState();
}

class _CreateScheduleMessageState extends State<CreateScheduleMessage> {
  late DateTime selectedDate = DateTime.now();
  TextEditingController messageController = TextEditingController();
  TextEditingController tahunController = TextEditingController();
  TextEditingController progdiController = TextEditingController();
  List<PlatformFile> files = [];

  Future<void> sendPostRequest() async {
    var url = 'http://localhost:8080/create-schedule-message';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['message'] = messageController.text;
    request.fields['tahun'] = tahunController.text;
    request.fields['progdi'] = progdiController.text;
    request.fields['tanggal_kirim'] =
        formatDate(selectedDate, [dd, ' ', MM, ' ', yyyy]);

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
    if (response.statusCode == 200) {
      // Request successful
      print('Post request sent successfully');
    } else {
      // Request failed
      print('Error sending post request');
    }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Schedule Message"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                // ignore: unnecessary_null_comparison
                text: selectedDate != null
                    ? formatDate(selectedDate, [dd, ' ', MM, ' ', yyyy])
                    : '',
              ),
              onTap: () {
                _selectDate(context);
              },
              decoration: const InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            TextField(
              controller: tahunController,
              decoration: InputDecoration(labelText: 'Tahun'),
            ),
            TextField(
              controller: progdiController,
              decoration: InputDecoration(labelText: 'Progdi'),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                await sendPostRequest();
              },
              child: Text('Send Request'),
            ),
            SizedBox(
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
    );
  }
}
