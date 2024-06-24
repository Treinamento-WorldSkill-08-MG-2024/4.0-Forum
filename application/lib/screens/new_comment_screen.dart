import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:flutter/material.dart';

class NewCommentScreen extends StatelessWidget {
  final String? originCommentAuthor;
  final String? originCommentContent;

  NewCommentScreen({super.key, this.originCommentAuthor, this.originCommentContent});

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Styles.defaultSpacing),
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Styles.orange),
              onPressed: () async {
                _formKey.currentState!.save();
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final newPost = PostModel(
                  null,
                  _contentController.text,
                  _titleController.text,
                  true,
                  DateTime.now().toString(),
                  2,
                  0,
                  0,
                );

                final ok = await PublicationHandler().newPost(2, newPost);

                if (!context.mounted) {
                  return;
                }

                if (ok) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Enviar"),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(Styles.defaultSpacing),
          child: Column(
            children: [
              originCommentAuthor != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(originCommentAuthor!),
                        Text(originCommentContent!),
                        const Divider(),
                      ],
                    )
                  : Container(),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Seu comentário",
                    hintStyle: TextStyle(fontSize: 16),
                    // counter: SizedBox(),
                  ),
                  style: const TextStyle(fontSize: 15),
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  controller: _titleController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
