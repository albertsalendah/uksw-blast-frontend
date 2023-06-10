
import 'package:blast_whatsapp/history.dart';
import 'package:blast_whatsapp/home.dart';
import 'package:flutter/material.dart';

class SideNavigationBar extends StatelessWidget {
   final List<String> navigationItems = [
    'Home',
    'History',
  ];
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
                  builder: (context) => buildScreenByIndex(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

  Widget buildScreenByIndex(int index) {
    // Return the respective screen or class based on the index
    switch (index) {
      case 0:
        return Home();
      case 1:
        return History();
      default:
        return Home();
    }
  }
