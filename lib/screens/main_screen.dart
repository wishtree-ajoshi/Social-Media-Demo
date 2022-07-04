import 'package:ajoshi_socialmedia_demo/screens/posts_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/user_profile.dart';
import 'package:ajoshi_socialmedia_demo/screens/users_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

Color primaryColor = Colors.grey.shade200;

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TabController? tabController;
  Map userProfile = {};
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(2),
          height: 50,
          color: primaryColor,
          child: TabBar(
            indicator: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.black26),
            controller: tabController,
            tabs: [
              tabColumn(imagePath: "assets/home.png"),
              tabColumn(imagePath: "assets/group.png"),
              tabColumn(imagePath: "assets/profile.png"),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            const PostsScreen(),
            const UsersScreen(),
            UserProfile(
              userId: '60d0fe4f5311236168a109d0',
              userProfile: userProfile,
            ),
          ],
        ));
  }
}

tabColumn({
  String imagePath = "",
  String label = '',
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          imagePath,
          width: 25,
          height: 25,
        ),
      ),
    ],
  );
}
