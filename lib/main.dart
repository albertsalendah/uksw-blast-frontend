import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:blast_whatsapp/pages/home.dart';
import 'package:blast_whatsapp/utils/SessionManager.dart';
import 'package:blast_whatsapp/utils/link.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'socket/socket_provider.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await SessionManager.isUserLoggedIn();
  final isSessionExpired = await SessionManager.isSessionExpired();
  runApp(
    ChangeNotifierProvider(
      create: (_) => SocketProvider(),
      child: MyApp(isLoggedIn: isLoggedIn && !isSessionExpired),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  String link = Links().link;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool loading = true;
  bool mainmenuV = false;
  bool showQR = false;
  String qr = '';
  late SocketProvider socketProvider;
  String logs = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketProvider = Provider.of<SocketProvider>(context, listen: false);
      socketProvider.connectToSocket();

      if (socketProvider.loading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });

    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.updateLoading = handleLoading;
    socketProvider.updateMainMenu = handleMainMenu;
    socketProvider.updateQR = handleQR;
    socketProvider.QR = handleQRCode;
    socketProvider.messages = handleLog;
    // Future.delayed(const Duration(seconds: 5), () {
    //   setState(() {});
    // });
  }

  Future<void> login() async {
    final url = Uri.parse('${link}login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'username': usernameController.text,
          'password': passController.text,
        },
      ),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      // Do something with the token
      await SessionManager.saveToken(token);
      setState(() {});
      window.location.reload();
    } else {
      final message = jsonDecode(response.body)['message'];
      print('Login failed: $message');
    }
  }

  void handleLog(String log) {
    setState(() {
      logs = log;
    });
  }

  void handleQRCode(String message) {
    setState(() {
      qr = message;
    });
  }

  void handleLoading(bool message) {
    setState(() {
      loading = message;
    });

    if (loading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  void handleMainMenu(bool message) {
    setState(() {
      mainmenuV = message;
    });
  }

  void handleQR(bool message) {
    setState(() {
      showQR = message;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket?.disconnect();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketProvider = Provider.of<SocketProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.isLoggedIn;
    if (isLoggedIn) {
      if (loading) {
        return MaterialApp(
            home: Scaffold(
                body: Center(
                    child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo(),
            const SizedBox(
              height: 16,
            ),
            Text(logs)
          ],
        ))));
      } else if (showQR) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Visibility(
                visible: showQR,
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: QrImageView(
                    data: qr,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (mainmenuV) {
        return const MaterialApp(
          home: Scaffold(
            body: Home(),
          ),
        );
        // return FutureBuilder(
        //   future: Future.delayed(const Duration(seconds: 5)),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       _controller.repeat();
        //       return logo();
        //     } else {
        //       _controller.stop();
        //       _controller.dispose();

        //     }
        //   },
        // );
      } else {
        return const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        );
      }
    } else {
      return MaterialApp(
        home: Scaffold(
            body: Center(
          child: SizedBox(
            height: 220,
            width: 300,
            child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Center(child: Text("Login")),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                        minLines: 1,
                        keyboardType: TextInputType.name,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        controller: usernameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            contentPadding: EdgeInsets.all(10),
                            labelText: 'Username'),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextField(
                        minLines: 1,
                        keyboardType: TextInputType.visiblePassword,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        controller: passController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            contentPadding: EdgeInsets.all(10),
                            labelText: 'Password'),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                              onPressed: () async {
                                await login();
                              },
                              child: const Text("Login")))
                    ],
                  ),
                )),
          ),
        )),
      );
    }
  }

  bool isPressd = false;

  Widget logo() {
    Offset distance = isPressd ? const Offset(10, 10) : const Offset(20, 20);
    double blur = isPressd ? 5.0 : 30.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      child: SizedBox(
        width: 115,
        height: 115,
        child: Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade500,
                  offset: distance,
                  blurRadius: blur,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: -distance,
                  blurRadius: blur,
                  //inset: isPressd
                ),
              ],
            ),
            child: RotationTransition(
              turns: _animation,
              child: SizedBox(
                height: 100,
                width: 100,
                child: Image.asset(
                  "assets/uksw.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
