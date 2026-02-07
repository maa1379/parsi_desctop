import 'package:flutter/material.dart';
import 'package:parsi/main.dart';

import 'flushbar/flushbar.dart';

class ViewHelper {
  // static Image pattern = Image.asset('assets/images/pattern.jpg');

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 50,
            width: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  //
  // static void dismissLoading() {
  //   Get.close(0);
  // }

  static void showErrorDialog(String text, BuildContext context) {
    Flushbar(
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      borderColor: Colors.red,
      margin: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 150.0,
      ),
      animationDuration: const Duration(milliseconds: 500),
      messageText: Text(
        text,
        maxLines: 1,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
      flushbarPosition: FlushbarPosition.BOTTOM,
      icon: const Icon(
        Icons.error_outline,
        size: 28.0,
        color: Colors.red,
      ),
      duration: const Duration(seconds: 3),
    ).show(navigatorKey.currentState!.context);
  }

  static void showSuccessDialog(String text, BuildContext context) {
    Flushbar(
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      borderColor: Colors.green.shade700,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
      animationDuration: const Duration(milliseconds: 500),
      messageText: Text(
        text,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      flushbarPosition: FlushbarPosition.BOTTOM,
      icon: const Icon(
        Icons.check_circle,
        size: 28.0,
        color: Colors.black,
      ),
      duration: const Duration(seconds: 3),
    ).show(navigatorKey.currentState!.context);
  }
}
