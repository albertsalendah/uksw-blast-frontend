// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ImageDialog extends StatefulWidget {
  final int currentImageIndex;

  const ImageDialog({super.key, required this.currentImageIndex});

  @override
  // ignore: library_private_types_in_public_api
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  late int currentIndex;
  final List<String> imagePaths = [
    'assets/1.png',
    'assets/2.png',
    'assets/3.png',
    'assets/4.png',
    // Add more image paths here
  ];

  @override
  void initState() {
    currentIndex = widget.currentImageIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Image.asset(
                      imagePaths[currentIndex],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              color: (currentIndex == 0 || currentIndex == 1) ? Colors.green : Colors.red,
              child: Wrap(
                children: [
                  const SizedBox(width: 8),
                  Center(
                    child: Text(
                        (currentIndex == 0 || currentIndex == 1)
                            ? "Contoh Format File Yang Benar"
                            : "Contoh Format File Yang Salah",
                        style: TextStyle(color: Colors.grey[900],fontWeight: FontWeight.bold,fontSize: 16)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,color: Colors.grey[900]),
                        onPressed: () {
                          setState(() {
                            if (currentIndex > 0) {
                              currentIndex--;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Image ${currentIndex + 1} of ${imagePaths.length}',
                        style: TextStyle(fontSize: 16,color: Colors.grey[900]),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon:  Icon(Icons.arrow_forward,color: Colors.grey[900]),
                        onPressed: () {
                          setState(() {
                            if (currentIndex < imagePaths.length - 1) {
                              currentIndex++;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
