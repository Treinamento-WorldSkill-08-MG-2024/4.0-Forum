import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Toasts {
  static AlertDialog successDialog(final String message) {
    return AlertDialog(content: Text(message));
  }

  static AlertDialog failureDialog(final String message) {
    return AlertDialog(content: Text(message));
  }

  static AlertDialog imageSourceDialog(
    BuildContext context,
    void Function(ImageSource) onPick,
  ) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            onPick(ImageSource.camera);
            Navigator.of(context).pop();
          },
          child: const Text("Camera"),
        ),
        TextButton(
          onPressed: () {
            onPick(ImageSource.gallery);
            Navigator.of(context).pop();
          },
          child: const Text("Galeria"),
        ),
      ],
    );
  }
}
