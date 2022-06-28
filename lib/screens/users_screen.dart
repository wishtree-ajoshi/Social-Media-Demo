import 'package:ajoshi_socialmedia_demo/api_call/api_call.dart';
import 'package:ajoshi_socialmedia_demo/screens/main_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late ScrollController scrollController;
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  int userLength = 0;
  int page = 1;
  int limit = 10;
  Map users = {};

  @override
  void initState() {
    scrollController = ScrollController()..addListener(loadMore);
    firstTimeLoad();
    super.initState();
  }

  void firstTimeLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    final res = await ApiCall().usersList(page, limit);
    setState(() {
      users = json.decode(res.body);
      userLength = users['data'].length;
      print("=======${users}");
    });
    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      setState(() {
        isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      page += 1; // Increase page by 1
      try {
        final res = await ApiCall().usersList(page, limit);
        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            users['data'].addAll(fetchedPosts['data']);
            userLength = users['data'].length;
            print("=======${users['data'].length}");
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
    scrollController.removeListener(loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text(
          'Users',
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
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    controller: scrollController,
                    itemCount: userLength,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserProfile(
                                    users: users,
                                    userId: users['data'][index]['id'],
                                  ))),
                      child: Card(
                        elevation: 15,
                        color: primaryColor,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image(
                                image: NetworkImage(
                                    "${users['data'][index]['picture']}"),
                                fit: BoxFit.fill,
                                height: 100,
                                width: 100,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Text(
                                      "${users['data'][index]['firstName']} ${users['data'][index]['lastName']}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                  ),
                ),

                // when the loadMore function is running
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
                      child: Text('You have fetched all of the content'),
                    ),
                  ),
              ],
            ),
    );
  }
}
