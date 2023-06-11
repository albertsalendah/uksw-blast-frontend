import 'dart:convert';

import 'package:blast_whatsapp/history.dart';
import 'package:blast_whatsapp/home.dart';
import 'package:blast_whatsapp/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SideNavigationBar extends StatelessWidget {
  final List<String> navigationItems = ['Home', 'History', 'Logout'];

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
      return const History();
    case 2:
      Future<void> logout() async {
        String link = 'http://uksw-blast-api.marikhsalatiga.com/';
        //String link = 'http://localhost:8080/';
        try {
          final historyResponse =
              await http.get(Uri.parse('${link}logout'));
          if (historyResponse.statusCode == 200) {
            dynamic Data = jsonDecode(historyResponse.body);
            print(Data);
          } else {
            print('Failed to send data. Error: ${historyResponse.statusCode}');
          }
        } catch (e) {
          print(e);
        }
      }
      return AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              logout();
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => MyApp()),
              //   (route) => false, // Clear the navigation stack
              // );
            },
            child: const Text('Logout'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    default:
      return const Home();
  }
}
