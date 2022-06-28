import 'package:ajoshi_socialmedia_demo/api_call/api_call.dart';
import 'package:ajoshi_socialmedia_demo/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class UserProfile extends StatefulWidget {
  Map users = {};
  String userId = "";

  UserProfile({
    Key? key,
    required this.users,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late ScrollController scrollController;
  Map userProfile = {};
  Map userPosts = {};
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  int postsLength = 0;
  int page = 1;
  int limit = 10;

  @override
  void initState() {
    scrollController = ScrollController()..addListener(loadMoreData);
    firstLoadData();
    super.initState();
  }

  void firstLoadData() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    try {
      if (widget.userId == '') {
        widget.userId = '60d0fe4f5311236168a109d0';
      }
      final res1 = await ApiCall().userProfile(page, limit, widget.userId);
      final res2 = await ApiCall().userPosts(page, limit, widget.userId);
      setState(() {
        userProfile = json.decode(res1.body);
        userPosts = json.decode(res2.body);
        postsLength = userPosts['data'].length;
      });
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }

    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMoreData() async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      setState(() {
        isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      page += 1; // Increase page by 1
      try {
        final res = await ApiCall().userPosts(page, limit, widget.userId);
        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            userPosts['data'].addAll(fetchedPosts['data']);
            postsLength = userPosts['data'].length;
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            hasNextPage = false;
          });
        }
      } catch (err) {
        print("$err");
        print('Something went wrong!');
      }

      setState(() {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Colors.black,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        Image(
                          image: NetworkImage("${userProfile['picture']}"),
                          fit: BoxFit.fitWidth,
                          height: 70,
                          width: 70,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Text(
                                  "${userProfile['firstName']} ${userProfile['lastName']}"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GridView.builder(
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: postsLength,
                            itemBuilder: (context, index) => Card(
                              color: primaryColor,
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
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                          ),
                        ),
                        if (isLoadMoreRunning == true)
                          const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 40),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),

                        // When nothing else to load
                        if (hasNextPage == false)
                          Container(
                            padding: const EdgeInsets.only(top: 30, bottom: 40),
                            color: Colors.amber,
                            child: const Center(
                              child:
                                  Text('You have fetched all of the content'),
                            ),
                          ),
                      ],
                    ),

                    //when the loadMore function is running
                  ),
                ),
              ],
            ),
    );
  }
}
