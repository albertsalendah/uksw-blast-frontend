import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class NOTIF_SCREEN {
  popUpError(BuildContext context, w,String text) {
    AwesomeDialog(width: w,
      context: context,
      showCloseIcon: true,
      closeIcon: const Icon(
        Icons.close_rounded,
      ),
      autoHide: const Duration(seconds: 3),
      animType: AnimType.scale,
      dialogType: DialogType.error,
      title: 'ERROR',
      desc: text,
    ).show();
  }
  popUpSuccess(BuildContext context, w,String text) {
    AwesomeDialog(width: w,
      context: context,
      showCloseIcon: true,
      closeIcon: const Icon(
        Icons.close_rounded,
      ),
      autoHide: const Duration(seconds: 3),
      animType: AnimType.scale,
      dialogType: DialogType.success,
      title: 'SUCCESS',
      desc: text,
    ).show();
  }
}
