import 'package:application/design/styles.dart';
import 'package:application/modules/publications_modules.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewCommentScreen extends StatelessWidget {
  final IPublicationModel _originPublication;
  final String? _originAuthor;

  final bool _isReply;

  NewCommentScreen(this._originPublication, {super.key, String? originAuthor})
      : _isReply = _originPublication is CommentModel,
        _originAuthor = originAuthor,
        assert(_originPublication is! CommentModel || originAuthor != null),
        assert(_originPublication is! CommentModel ||
            _originPublication.id != null);

  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isReply ? "Resposta" : "Novo comentário",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(187, 0, 0, 0),
          ),
        ),
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

                final currentUser =
                    Provider.of<AuthProvider>(context, listen: false).currentUser;
                if (currentUser == null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                }

                assert(currentUser!.id != null);
                final newComment = CommentModel(
                  null,
                  _contentController.text,
                  true,
                  currentUser!.id!,
                  _isReply ? null : _originPublication.id,
                  _isReply ? _originPublication.id : null,
                );

                final ok = await PublicationHandler.given(newComment)
                    .newPublication(currentUser.id!);

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
              _isReply
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_originAuthor!),
                        Text(_originPublication.content),
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
                  controller: _contentController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
