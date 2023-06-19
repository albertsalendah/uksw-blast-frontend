import 'package:flutter_dotenv/flutter_dotenv.dart';
class Links {
  static final Links _instance = Links._internal();

  factory Links() {
    return _instance;
  }

  Links._internal();

  String link = dotenv.env['LOCAL_LINK'].toString();
}
