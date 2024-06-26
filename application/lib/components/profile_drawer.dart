import 'package:application/modules/auth_modules.dart';
import 'package:application/providers/auth_provider.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, value, child) {
      // value.redirectIfNotAuthenticated(context);
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _drawerContent(context, value.currentUser!),
        ),
      );
    });
  }

  List<Widget> _drawerContent(BuildContext context, UserModel currentUser) {
    return [
      DrawerHeader(
        decoration: const BoxDecoration(color: Colors.orange),
        child: Text(currentUser.name),
      ),
      ListTile(
        title: const Text("Logout"),
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Você tem certeza?"),
            content: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final ok = await prefs.remove(UserModelFields.token);

                      if (!ok) {
                        throw Exception("Failed to logout");
                      }
                    } catch (error) {
                      if (kDebugMode) {
                        print(error);
                      }

                      // TODO - show error dialog
                    }

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Sim"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Não"),
                )
              ],
            ),
          ),
        ),
      )
    ];
  }
}
