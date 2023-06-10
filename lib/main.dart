import 'package:blast_whatsapp/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'socket/socket_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SocketProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool loading = true;
  bool mainmenuV = false;
  bool showQR = false;
  String qr = '';
  late SocketProvider socketProvider;

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
      socketProvider =
          Provider.of<SocketProvider>(context, listen: false);
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

    if (message) {
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
    if (loading) {
      return MaterialApp(home: Scaffold(body: Center(child: logo())));
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
    } else {
      return const MaterialApp(
        home: Scaffold(body: Text("Null")),
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
