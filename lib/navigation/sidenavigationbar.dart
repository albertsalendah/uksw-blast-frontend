// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:blast_whatsapp/pages/extra_data.dart';
import 'package:blast_whatsapp/pages/history.dart';
import 'package:blast_whatsapp/pages/home.dart';
import 'package:blast_whatsapp/pages/uploaded_excel_file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/SessionManager.dart';
import '../utils/link.dart';

class SideNavigationBar extends StatelessWidget {
  final List<String> navigationItems = ['Home',"Uploaded Excel File",'Extra Data','History','Logout'];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        itemCount: navigationItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(navigationItems[index]),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigate to the selected screen or class
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => buildScreenByIndex(index, context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Widget buildScreenByIndex(int index, BuildContext context) {
  // Return the respective screen or class based on the index
  switch (index) {
    case 0:
      return const Home();
    case 1:
      return const UplodaedExcelFileList();
    case 2:
      return const ExtraData();
    case 3:
      return const History();
    case 4:
      bool logs = false;
      Future<void> logout() async {
        final String link = Links().link;
        try {
          final historyResponse = await http.get(Uri.parse('${link}logout'));
          if (historyResponse.statusCode == 200) {
            dynamic data = jsonDecode(historyResponse.body);
            print(data);
          } else {
            print('Failed to send data. Error: ${historyResponse.statusCode}');
          }
        } catch (e) {
          print("Error Logout $e");
        }
      }
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Logout'),
            content: Wrap(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: logs,
                          onChanged: (value) {
                            setState(
                              () {
                                logs = !logs;
                              },
                            );
                          },
                        ),
                        const Text("Centang Untuk Logout Whatsapp"),
                      ],
                    ),
                    const Text('Are you sure you want to logout?'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (logs) {
                    print(logs);
                    await logout();
                  }
                  await SessionManager.logout();
                },
                child: const Text('Logout'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    default:
      return const Home();
  }
}
