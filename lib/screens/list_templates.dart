import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/template_pesan.dart';
import '../utils/link.dart';

class List_Templates {
  final String link = Links().link;
  List<Template_Pesan> daftar_template = [];
  final TextEditingController _kategoriPesanController =
      TextEditingController();
  final TextEditingController _isiPesanController = TextEditingController();

  Future<void> deleteTemplatePesan(String messageId) async {
    final url = '${link}delete_template_pesan/$messageId';

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      // Data deleted successfully
      print('Data deleted from MongoDB');
    } else {
      // Error deleting data
      print('Failed to delete data from MongoDB');
    }
  }

  Future<void> _updateTemplatePesan(String id) async {
    final String kategoriPesan = _kategoriPesanController.text;
    final String isiPesan = _isiPesanController.text;

    // Send the update request to the backend API
    final response = await http.put(
      Uri.parse('${link}edit_template_pesan/${id}'),
      body: {
        'kategori_pesan': kategoriPesan,
        'isi_pesan': isiPesan,
      },
    );

    if (response.statusCode == 200) {
      // Data updated successfully
      // You can handle the success case based on your requirements
      //Navigator.of(context).pop();
    } else {
      // Update failed
      // You can handle the error case based on your requirements
      print('Update failed: ${response.statusCode}');
    }
  }

  showdaftarTemplateAlertDialog(
      BuildContext context,
      TextEditingController kategoriPesan,
      TextEditingController messageController,
      List<Template_Pesan> daftar_template) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Daftar Template Pesan'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: daftar_template.length,
                itemBuilder: (ctx, index) => ListTile(
                  title: InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(daftar_template[index].kategoriPesan),
                        SizedBox(height: 8,),
                        Text(daftar_template[index].isiPesan),
                      ],
                    ),
                    onTap: () {
                      kategoriPesan.text = daftar_template[index].kategoriPesan;
                      messageController.text = daftar_template[index].isiPesan;
                      Navigator.of(context).pop();
                    },
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              final updatedItem = daftar_template[index];
                              _showUpdateDialog(context, updatedItem);
                            },
                            icon: const Icon(Icons.edit)),
                        const SizedBox(
                          width: 8,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await deleteTemplatePesan(
                                daftar_template[index].id);
                            Navigator.of(context).pop();
                            //await fetchdaftarTemplate;
                            // setState(() {

                            //   showdaftarTemplateAlertDialog(
                            //       context,
                            //       kategoriPesan,
                            //       messageController,
                            //       daftar_template,
                            //       fetchdaftarTemplate);
                            // });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Kembali'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showUpdateDialog(BuildContext context, Template_Pesan currentItem) {
    _kategoriPesanController.text = currentItem.kategoriPesan;
    _isiPesanController.text = currentItem.isiPesan;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Update Item'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  TextField(
                    controller: _kategoriPesanController,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Pesan',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    controller: _isiPesanController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                        contentPadding: EdgeInsets.all(10),
                        labelText: 'Isi Pesan'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _updateTemplatePesan(currentItem.id);
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
      },
    );
  }
}

// class MyPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 // Define a variable to hold the data
//                 List<String> data = [];

//                 return StatefulBuilder(
//                   builder: (BuildContext context, StateSetter setState) {
//                     // Method to fetch data asynchronously
//                     Future<void> fetchData() async {
//                       // Simulating the data fetch with a delay of 2 seconds
//                       await Future.delayed(Duration(seconds: 2));

//                       // Update the data
//                       setState(() {
//                         data = ['Item 1', 'Item 2', 'Item 3'];
//                       });
//                     }

//                     // Call the method to fetch data when the dialog is built
//                     fetchData();

//                     return AlertDialog(
//                       title: Center(child: Text("Data")),
//                       content: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (data.isEmpty)
//                             CircularProgressIndicator() // Show a loading indicator if data is empty
//                           else
//                             ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: data.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 return ListTile(
//                                   title: Text(data[index]),
//                                 );
//                               },
//                             ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           },
//           child: Text('Show Dialog'),
//         ),
//       ),
//     );
//   }
// }
