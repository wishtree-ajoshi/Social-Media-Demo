import 'package:ajoshi_socialmedia_demo/api_call/api_call.dart';
import 'package:ajoshi_socialmedia_demo/main.dart';
import 'package:ajoshi_socialmedia_demo/screens/main_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/post_details.dart';
import 'package:ajoshi_socialmedia_demo/screens/posts_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

class UserProfile extends StatefulWidget {
  Map userProfile = {};
  String userId = "";

  UserProfile({
    Key? key,
    required this.userProfile,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;
  Map userPosts = {};
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  int postsLength = 0;
  int page = 0;
  int limit = 15;
  String userEmail = "";

  @override
  void initState() {
    scrollController = ScrollController()..addListener(loadMoreData);
    firstLoadData();
    super.initState();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void checkInternetConnection() async {
    internetConnection = await ApiCall().checkUserConnection();
    if (internetConnection == true && postsLength == 0) {
      firstLoadData();
    }
  }

  void firstLoadData() async {
    setStateIfMounted(() {
      isFirstLoadRunning = true;
    });
    try {
      if (widget.userId == '') {
        widget.userId = '60d0fe4f5311236168a109d0';
      }
      final res1 = await ApiCall().userProfile(page, limit, widget.userId);
      final res2 = await ApiCall().userPosts(page, limit, widget.userId);
      setStateIfMounted(() {
        widget.userProfile = json.decode(res1.body);
        userPosts = json.decode(res2.body);
        postsLength = userPosts['data'].length;
        userEmail = "${widget.userProfile['location']['country']}";
      });
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }

    setStateIfMounted(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMoreData() async {
    print("mai load more data me hoon");
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      setStateIfMounted(() {
        isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      page += 1; // Increase page by 1
      print("$page no hoon");
      try {
        final res = await ApiCall().userPosts(page, limit, widget.userId);
        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts['data'].isNotEmpty) {
          setStateIfMounted(() {
            userPosts['data'].addAll(fetchedPosts['data']);
            postsLength = userPosts['data'].length;
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
    scrollController.removeListener(loadMoreData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: primaryColor,
          title: const Text(
            'Profile',
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
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 10,
                                        top: 20,
                                        bottom: 10),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                          "${widget.userProfile['picture']}"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${widget.userProfile['firstName']} ${widget.userProfile['lastName']}",
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          userEmail,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          "${widget.userProfile['email']}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: GridView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: postsLength,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PostDetails(
                                                  postDetails: userPosts['data']
                                                      [index],
                                                ))),
                                    child: Card(
                                      color: Colors.black54,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 2),
                                      child: Image(
                                        image: NetworkImage(
                                            "${userPosts['data'][index]['image']}"),
                                        fit: BoxFit.cover,
                                        height: 120,
                                        width: 120,
                                      ),
                                    ),
                                  ),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3),
                                ),
                              ),
                              if (isLoadMoreRunning == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 20),
                                  child: Center(
                                    child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white10),
                                        child: const CircularProgressIndicator(
                                          color: Colors.black,
                                        )),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AlertDialog(
                  title: const Text('No Internet !!'),
                  content: const Text('Please check your internet connection'),
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
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MyApp(),
                        ));
                      },
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
