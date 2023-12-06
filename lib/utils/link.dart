import 'package:blast_whatsapp/utils/config.dart';

class Links {
  static final Links _instance = Links._internal();

  factory Links() {
    return _instance;
  }

  Links._internal();

  String link = Configs.LOCAL_LINK;
}
