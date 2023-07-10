// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:blast_whatsapp/pages/extra_data.dart';
import 'package:blast_whatsapp/pages/history.dart';
import 'package:blast_whatsapp/pages/home.dart';
import 'package:blast_whatsapp/pages/uploaded_excel_file.dart';
import 'package:blast_whatsapp/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/userprofile.dart';
import '../socket/socket_provider.dart';
import '../utils/SessionManager.dart';
import '../utils/link.dart';

class SideNavigationBar extends StatefulWidget {
  const SideNavigationBar({super.key});

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarState();
}

class _SideNavigationBarState extends State<SideNavigationBar> {
  late SocketProvider socketProvider;
  UserProfile user = UserProfile();
  final List<String> navigationItems = [
    'Home',
    "Uploaded Excel File",
    'Extra Data',
    'History',
    'Logout'
  ];
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

  @override
  void initState() {
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    handleUserProfile(socketProvider);
    super.initState();
  }

  void handleUserProfile(SocketProvider socketProvider) {
    setState(() {
      user = socketProvider.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Stack(
      children: [
        Image.asset("assets/whatsapp_Back.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitHeight),
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (user.profilepicture != null) ? NetworkImage(user.profilepicture!) : const AssetImage("assets/uksw.png") as ImageProvider<Object>?,
                  ),
                  const SizedBox(height: 8,),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((user.username != null) ? user.username! : '',style:  TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey[900])),
                        const SizedBox(height: 4,),
                        Text((user.userid != null) ? "+${user.userid!}" : '',style:  TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.grey[900]))
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Divider(color: Colors.grey,height: 1,),
            const SizedBox(height: 8,),
            ListTile(
              title: Text(
                "Home",
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Navigate to the selected screen or class
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                "Uploaded Excel File",
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Navigate to the selected screen or class
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UplodaedExcelFileList(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                "Extra Data",
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Navigate to the selected screen or class
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExtraData(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                "History",
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Navigate to the selected screen or class
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const History(),
                  ),
                );
              },
            ),
            const Divider(
              color: Colors.grey,
              height: 1,
            ),
            ListTile(
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Navigate to the selected screen or class
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) {
                        return Stack(
                          children: [
                            Image.asset("assets/whatsapp_Back.png",
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover),
                            AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              content: Wrap(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: FractionallySizedBox(
                                      widthFactor: 1.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Configs().green,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Logout',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                const Text(
                                                    "Centang Untuk Logout Whatsapp"),
                                              ],
                                            ),
                                          ),
                                          const Center(
                                              child: Text(
                                                  'Are you sure you want to logout?')),
                                        ],
                                      ),
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
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            )
          ],
        ),
        // ListView.separated(
        //   itemCount: navigationItems.length,
        //   separatorBuilder: (context, index) => Divider(
        //     color: Colors.grey[800], // Adjust the color as per your preference
        //   ),
        //   itemBuilder: (context, index) {
        //     return ListTile(
        //       title: Text(
        //         navigationItems[index],
        //         style: TextStyle(
        //           color: Colors.grey[900],
        //           fontSize: 16,
        //         ),
        //       ),
        //       onTap: () {
        //         Navigator.of(context).pop(); // Close the drawer
        //         // Navigate to the selected screen or class
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => buildScreenByIndex(index, context),
        //           ),
        //         );
        //       },
        //     );
        //   },
        // ),
      ],
    ));
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
          return Stack(
            children: [
              Image.asset("assets/whatsapp_Back.png",
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover),
              AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Wrap(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Configs().green,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      children: [
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                            ),
                            const Center(
                                child:
                                    Text('Are you sure you want to logout?')),
                          ],
                        ),
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
              ),
            ],
          );
        },
      );
    default:
      return const Home();
  }
}
