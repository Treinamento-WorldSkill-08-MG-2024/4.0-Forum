import 'package:application/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Text("Header"),
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
                      onPressed: () {
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
        ],
      ),
    );
  }
}
