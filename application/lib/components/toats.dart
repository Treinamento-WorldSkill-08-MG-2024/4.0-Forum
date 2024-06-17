import 'package:flutter/material.dart';

class Toasts {
  static AlertDialog successDialog(final String message) {
    return AlertDialog(content: Text(message));
  }

  static AlertDialog failureDialog(final String message) {
    return AlertDialog(content: Text(message));
  }
}
