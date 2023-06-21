import 'package:flutter/material.dart';

// ignore: camel_case_types
class NOTIF_SCREEN {
  static void show(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: Text(title)),
                  const SizedBox(
                    height: 16,
                  ),
                  Center(child: Text(content)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
