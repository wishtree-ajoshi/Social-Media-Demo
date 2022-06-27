import 'package:ajoshi_socialmedia_demo/screens/posts_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/user_profile.dart';
import 'package:ajoshi_socialmedia_demo/screens/users_screen.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TabController? tabController;
  Color primaryColor = Colors.grey.shade200;
  //late ScrollController scrollController;

  String baseUrl = 'https://dummyapi.io/data/v1/';
  int page = 1;
  int limit = 10;
  String appId = "62b2b78d1af170c63fe12335";
  String category = '';
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  Map posts = {};

  // void firstLoad(int tabId) async {
  //   setState(() {
  //     isFirstLoadRunning = true;
  //   });
  //   try {
  //     if (tabId == 1) {
  //       category = 'user';
  //     } else if (tabId == 2) {
  //       category = 'user';
  //     }
  //     final res = await http.get(
  //         Uri.parse("$baseUrl$category?page=$page&limit=$limit}"),
  //         headers: {"app-id": appId});
  //     setState(() {
  //       posts = json.decode(res.body);
  //       print("=======$posts");
  //     });
  //   } catch (err) {
  //     print("$err");
  //     print('Something went wrong');
  //   }

  //   setState(() {
  //     isFirstLoadRunning = false;
  //   });
  // }

  // void loadMore() async {
  //   if (hasNextPage == true &&
  //       isFirstLoadRunning == false &&
  //       isLoadMoreRunning == false &&
  //       scrollController.position.extentAfter < 300) {
  //     setState(() {
  //       isLoadMoreRunning = true; // Display a progress indicator at the bottom
  //     });
  //     page += 1; // Increase page by 1
  //     try {
  //       final res = await http.get(
  //           Uri.parse("$baseUrl$category?page=$page&limit=$limit"),
  //           headers: {"app-id": appId});

  //       final Map fetchedPosts = json.decode(res.body);
  //       if (fetchedPosts.isNotEmpty) {
  //         setState(() {
  //           posts.addAll(fetchedPosts);
  //           print("=======$posts");
  //         });
  //       } else {
  //         // This means there is no more data
  //         // and therefore, we will not send another GET request
  //         setState(() {
  //           hasNextPage = false;
  //         });
  //       }
  //     } catch (err) {
  //       print("$err");
  //       print('Something went wrong!');
  //     }

  //     setState(() {
  //       isLoadMoreRunning = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    // scrollController = ScrollController()..addListener(loadMore);
    // firstLoad(tabController!.index);
    super.initState();
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
            PostsScreen(
                posts: posts,
                primaryColor: primaryColor,
                appId: appId,
                baseUrl: baseUrl,
                category: 'post',
                hasNextPage: hasNextPage,
                isFirstLoadRunning: isFirstLoadRunning,
                isLoadMoreRunning: isLoadMoreRunning,
                limit: limit,
                page: page),
            UsersScreen(
                posts: posts,
                primaryColor: primaryColor,
                appId: appId,
                baseUrl: baseUrl,
                category: 'user',
                hasNextPage: hasNextPage,
                isFirstLoadRunning: isFirstLoadRunning,
                isLoadMoreRunning: isLoadMoreRunning,
                limit: limit,
                page: page),
            UserProfile(
                userId: '60d0fe4f5311236168a109d0',
                posts: posts,
                primaryColor: primaryColor,
                appId: appId,
                baseUrl: baseUrl,
                category: 'user',
                hasNextPage: hasNextPage,
                isFirstLoadRunning: isFirstLoadRunning,
                isLoadMoreRunning: isLoadMoreRunning,
                limit: limit,
                page: page),
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
