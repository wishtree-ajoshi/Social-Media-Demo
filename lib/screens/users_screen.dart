import 'package:ajoshi_socialmedia_demo/api_call/api_call.dart';
import 'package:ajoshi_socialmedia_demo/main.dart';
import 'package:ajoshi_socialmedia_demo/screens/main_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/posts_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  int userLength = 0;
  int page = 0;
  int limit = 10;
  Map users = {};

  @override
  void initState() {
    scrollController = ScrollController()..addListener(loadMore);
    checkInternetConnection();
    super.initState();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void checkInternetConnection() async {
    internetConnection = await ApiCall().checkUserConnection();
    if (internetConnection == true && userLength == 0) {
      firstTimeLoad();
    }
  }

  void firstTimeLoad() async {
    setStateIfMounted(() {
      isFirstLoadRunning = true;
    });
    final res = await ApiCall().usersList(page, limit);
    setStateIfMounted(() {
      users = json.decode(res.body);
      userLength = users['data'].length;
    });
    setStateIfMounted(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    if (hasNextPage == true &&
        internetConnection == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      setStateIfMounted(() {
        isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      page += 1; // Increase page by 1
      try {
        final res = await ApiCall().usersList(page, limit);
        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts['data'].isNotEmpty) {
          setStateIfMounted(() {
            users['data'].addAll(fetchedPosts['data']);
            userLength = users['data'].length;
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setStateIfMounted(() {
            hasNextPage = false;
          });
        }
      } catch (err) {
        print("$err");
        print('Something went wrong!');
      }

      setStateIfMounted(() {
        isLoadMoreRunning = false;
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: primaryColor,
          title: const Text(
            'Users',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: internetConnection
            ? isFirstLoadRunning
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          controller: scrollController,
                          itemCount: userLength,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserProfile(
                                          userProfile: users,
                                          userId: users['data'][index]['id'],
                                        ))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.lightBlueAccent,
                                            blurRadius: 35,
                                            spreadRadius: 0.5,
                                            offset: Offset(0, 25)),
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image(
                                        image: NetworkImage(
                                            "${users['data'][index]['picture']}"),
                                        fit: BoxFit.fill,
                                        height: 100,
                                        width: 100,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${users['data'][index]['firstName']} ${users['data'][index]['lastName']}",
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                        ),
                      ),

                      // when the loadMore function is running
                      if (isLoadMoreRunning == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 40),
                          child: Center(
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white10),
                              child: const CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AlertDialog(
                    title: const Text('No Internet !!'),
                    content:
                        const Text('Please check your internet connection'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        },
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => const MyApp(),
                          ));
                        },
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ],
              ));
  }

  @override
  bool get wantKeepAlive => true;
}
