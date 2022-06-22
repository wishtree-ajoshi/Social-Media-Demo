import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TabController? tabController;
  Color primaryColor = Colors.grey.shade200;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(2),
          height: 60,
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
            Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text(
                  'Posts',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: const Text("......"),
            ),
            Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text(
                  "Users",
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: const Text("....."),
            ),
            Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: const Text("......."),
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
          width: 30,
          height: 30,
        ),
      ),
    ],
  );
}
