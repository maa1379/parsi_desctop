import 'package:flutter/material.dart';

class NavigatorHelper {
  static void push({
    required Widget page,
    required BuildContext context,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    debugPrint("****** Go to $page");
  }

  static void pushReplacement({
    required Widget page,
    required BuildContext context,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    debugPrint("****** Go to $page");
  }

  static void pushReplacementRemoveUntil({
    required Widget page,
    required BuildContext context,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
    debugPrint("****** Go to $page");
  }

  static void pop({required BuildContext context}) {
    Navigator.of(context).pop();
  }
}

extension NavHelper on BuildContext {
  to(page) {
    Navigator.push(this, MaterialPageRoute(builder: (_) => page));
    debugPrint("****** Go to $page");
  }

  rTo(page) {
    Navigator.pushReplacement(this, MaterialPageRoute(builder: (_) => page));
    debugPrint("****** Go to $page");
  }

  rAndRemoveUntilTo(page) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
    debugPrint("****** Go to $page");
  }

  pop() {
    Navigator.of(this).pop();
  }
}
