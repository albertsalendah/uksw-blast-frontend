import 'package:flutter/material.dart';

class NOTIF_SCREEN {
   static void show(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(title)),
          content: Text(content),
        );
      },
    );
  }
}


