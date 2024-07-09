import 'package:application/design/styles.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize; // default is 56.0

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const Border.symmetric(
        horizontal: BorderSide(color: Color.fromARGB(75, 36, 36, 36)),
      ),
      leading: !Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.stacked_bar_chart),
              onPressed: () {},
            )
          : const BackButton(),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              const SizedBox(width: Styles.defaultSpacing),
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.person_2_outlined),
                );
              })
            ],
          ),
        )
      ],
    );
  }
}
