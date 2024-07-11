import 'package:application/components/arch_bottom_bar.dart';
import 'package:application/components/home_app_bar.dart';
import 'package:application/components/posts/publicatons_feed.dart';
import 'package:application/components/profile_drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HomeAppBar(),
      body: SafeArea(
        child: Column(
          children: [PublicationsFeed()],
        ),
      ),
      endDrawer: ProfileDrawer(),
      bottomNavigationBar: ArchBottomBar(),
    );
  }
}
