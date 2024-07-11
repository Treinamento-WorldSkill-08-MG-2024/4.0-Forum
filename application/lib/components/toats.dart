import 'package:application/design/styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Toasts {
  static AlertDialog successDialog(final String message) {
    return AlertDialog(content: Text(message));
  }

  static AlertDialog failureDialog(final String message) {
    return AlertDialog(content: Text(message));
  }

  static Future<T> unwrapFutureInDialog<T>(
    Future<T> Function() valueFuture, {
    required BuildContext context,
  }) async {
    showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Espero um momento..."),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * .4,
            height: MediaQuery.of(context).size.width * .4,
            child: const Padding(
              padding: EdgeInsets.all(Styles.defaultSpacing),
              child: CircularProgressIndicator(
                color: Styles.orange,
              ),
            ),
          ),
        );
      },
    );

    final value = await valueFuture();
    if (!context.mounted) {
      return valueFuture();
    }

    Navigator.of(context).pop();

    return value;
  }

  static Widget imageSourceDialog(
    BuildContext context,
    void Function(ImageSource) onPick,
  ) {
    return AlertDialog(
      content: SizedBox(
        height: MediaQuery.of(context).size.height * .115,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                onPick(ImageSource.camera);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Tirar foto",
                style: TextStyle(color: Styles.black, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                onPick(ImageSource.gallery);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Escolher na galeria",
                style: TextStyle(color: Styles.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
