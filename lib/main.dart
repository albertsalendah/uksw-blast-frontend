// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:blast_whatsapp/pages/home.dart';
import 'package:blast_whatsapp/screens/notif_screen.dart';
import 'package:blast_whatsapp/utils/SessionManager.dart';
import 'package:blast_whatsapp/utils/config.dart';
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
      child: MaterialApp(
        home: MyApp(isLoggedIn: isLoggedIn && !isSessionExpired),
      ),
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
  bool loginbtn = false;
  Timer? _timer;
  bool pop = false;
  bool passwordVisible = false;
  TextEditingController admin = TextEditingController();
  TextEditingController adminPass = TextEditingController();
  TextEditingController register_username = TextEditingController();
  TextEditingController register_userpass = TextEditingController();
  bool adminpasswordVisible = false;
  bool register_passwordVisible = false;

  @override
  void initState() {
    super.initState();
    //startSessionTimer();
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
  }

  Future<void> login() async {
    setState(() {
      loginbtn = true;
    });
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
      final token = await jsonDecode(response.body)['token'];
      // Do something with the token
      await SessionManager.saveToken(token);
      setState(() {
        loginbtn = false;
        pop = false;
      });
      window.location.reload();
    } else {
      final message = await jsonDecode(response.body)['message'];
      setState(() {
        loginbtn = false;
        pop = true;
      });
      NOTIF_SCREEN()
          .popUpError(context, MediaQuery.of(context).size.width, message);
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

  void startSessionTimer() {
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final isSessionExpired = await SessionManager.isSessionExpired();
      if (isSessionExpired) {
        await SessionManager.logout();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    double width = MediaQuery.of(context).size.width;
    final isLoggedIn = widget.isLoggedIn;
    if (isLoggedIn) {
      if (loading) {
        return MaterialApp(
            home: Stack(
          children: [
            Image.asset("assets/whatsapp_Back.png",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover),
            Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: logo())),
          ],
        ));
      } else if (showQR && isLoggedIn) {
        return MaterialApp(
          home: Stack(
            children: [
              Image.asset("assets/whatsapp_Back.png",
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Visibility(
                    visible: showQR && isLoggedIn,
                    child: Card(
                      elevation: 3,
                      child: SizedBox(
                        height: 300,
                        width: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QrImageView(
                              data: qr,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              logs,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (mainmenuV) {
        return MaterialApp(
          theme: ThemeData(
              appBarTheme:
                  const AppBarTheme(color: Color.fromRGBO(0, 167, 131, 1)),
              primaryColor: const Color.fromRGBO(0, 167, 131, 1)),
          home: const Scaffold(
            body: Home(),
          ),
        );
      } else {
        return const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        );
      }
    } else {
      return MaterialApp(
        home: Stack(
          children: [
            Image.asset("assets/whatsapp_Back.png",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover),
            Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: (width > 827)
                        ? MediaQuery.of(context).size.width / 4
                        : 300,
                    child: Wrap(
                      children: [
                        Card(
                            elevation: 3,
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  width: (width > 827)
                                      ? MediaQuery.of(context).size.width / 4
                                      : 300,
                                  decoration: BoxDecoration(
                                    color: Config().green,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4)),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text("LOGIN",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        minLines: 1,
                                        keyboardType: TextInputType.name,
                                        maxLines: null,
                                        textInputAction:
                                            TextInputAction.newline,
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
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        maxLines: 1,
                                        obscureText: !passwordVisible,
                                        textInputAction:
                                            TextInputAction.newline,
                                        controller: passController,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide(),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            labelText: 'Password',
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                // Update the state i.e. toogle the state of passwordVisible variable
                                                setState(() {
                                                  passwordVisible =
                                                      !passwordVisible;
                                                });
                                              },
                                              icon: Icon(
                                                // Based on passwordVisible state choose the icon
                                                passwordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: Config().green,
                                              ),
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: SizedBox(
                                                child: Visibility(
                                                  visible: !loginbtn,
                                                  replacement:
                                                      const CircularProgressIndicator(),
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Config()
                                                                      .green),
                                                      onPressed: () async {
                                                        if (usernameController
                                                                .text
                                                                .isNotEmpty &&
                                                            passController.text
                                                                .isNotEmpty) {
                                                          await login();
                                                        } else {
                                                          loginbtn = false;
                                                          NOTIF_SCREEN().popUpError(
                                                              context,
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width,
                                                              "Username & Password Tidak Boleh Kosong");
                                                        }
                                                      },
                                                      child:
                                                          const Text("Login")),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                                onPressed: () {
                                                  Register();
                                                },
                                                child:
                                                    const Text("Tambah User")),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      );
    }
  }

  bool isPressd = false;

  Widget logo() {
    Offset distance = isPressd ? const Offset(10, 10) : const Offset(20, 20);
    double blur = isPressd ? 5.0 : 30.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
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
          const SizedBox(
            height: 16,
          ),
          Text(logs)
        ],
      ),
    );
  }

  Register() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Wrap(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Config().green,
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
                            'Register',
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
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          minLines: 1,
                          keyboardType: TextInputType.name,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          controller: admin,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                              contentPadding: EdgeInsets.all(10),
                              labelText: 'Admin'),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          keyboardType: TextInputType.visiblePassword,
                          maxLines: 1,
                          obscureText: !adminpasswordVisible,
                          textInputAction: TextInputAction.newline,
                          controller: adminPass,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                              contentPadding: const EdgeInsets.all(10),
                              labelText: 'Admin Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  setState(() {
                                    adminpasswordVisible =
                                        !adminpasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  // Based on adminpasswordVisible state choose the icon
                                  adminpasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Config().green,
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          minLines: 1,
                          keyboardType: TextInputType.name,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          controller: register_username,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                              contentPadding: EdgeInsets.all(10),
                              labelText: 'New Username'),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          keyboardType: TextInputType.visiblePassword,
                          maxLines: 1,
                          obscureText: !register_passwordVisible,
                          textInputAction: TextInputAction.newline,
                          controller: register_userpass,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                              contentPadding: const EdgeInsets.all(10),
                              labelText: 'New Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  // Update the state i.e. toogle the state of register_passwordVisible variable
                                  setState(() {
                                    register_passwordVisible =
                                        !register_passwordVisible;
                                  });
                                },
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  register_passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Config().green,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (admin.text.isNotEmpty &&
                        adminPass.text.isNotEmpty &&
                        register_username.text.isNotEmpty &&
                        register_userpass.text.isNotEmpty) {
                      regiteruser();
                    } else {
                      NOTIF_SCREEN().popUpError(
                          context,
                          MediaQuery.of(context).size.width,
                          "Username & Password Tidak Boleh Kosong");
                    }
                  },
                  child: const Text('Register'),
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
      },
    );
  }

  Future<void> regiteruser() async {
    final url = Uri.parse('${link}register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'admin': admin.text,
          'adminpass': adminPass.text,
          'username': register_username.text,
          'password': register_userpass.text,
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final message = await jsonDecode(response.body)['message'];
      Navigator.pop(context);
      NOTIF_SCREEN()
          .popUpSuccess(context, MediaQuery.of(context).size.width, message);
    } else {
      final message = await jsonDecode(response.body)['message'];
      Navigator.pop(context);
      NOTIF_SCREEN()
          .popUpError(context, MediaQuery.of(context).size.width, message);
    }
  }
}
