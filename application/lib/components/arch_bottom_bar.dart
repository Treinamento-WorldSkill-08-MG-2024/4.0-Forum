import 'package:application/screens/home/new_post_screen.dart';
import 'package:flutter/material.dart';

class ArchBottomBar extends StatefulWidget {
  const ArchBottomBar({super.key});

  @override
  State<ArchBottomBar> createState() => _ArchBottomBarState();
}

class _ArchBottomBarState extends State<ArchBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedFontSize: 0,
      unselectedFontSize: 0,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: ""),
      ],
      onTap: (value) {
        switch (value) {
          case 1:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const NewPostScreen()));
            break;

          case 2:
            Scaffold.of(context).openEndDrawer();
            break;

          case _:
            break;
        }
      },
    );
  }
}
