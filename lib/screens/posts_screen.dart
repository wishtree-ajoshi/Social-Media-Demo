import 'package:ajoshi_socialmedia_demo/api_call/api_call.dart';
import 'package:ajoshi_socialmedia_demo/screens/main_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/post_details.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../main.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

bool internetConnection = false;

class _PostsScreenState extends State<PostsScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  int postLength = 0;
  int page = 0;
  int limit = 10;
  Map posts = {};

  @override
  void initState() {
    checkInternetConnection();
    scrollController = ScrollController()..addListener(loadMoreData);
    super.initState();
  }

  void checkInternetConnection() async {
    internetConnection = await ApiCall().checkUserConnection();
    if (internetConnection == true && postLength == 0) {
      firstTimeLoad();
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void firstTimeLoad() async {
    setStateIfMounted(() {
      isFirstLoadRunning = true;
    });
    final res = await ApiCall().postsPage(page, limit);
    setStateIfMounted(() {
      posts = jsonDecode(res.body);
      postLength = posts['data'].length;
    });
    setStateIfMounted(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMoreData() async {
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
        final res = await ApiCall().postsPage(page, limit);
        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts['data'].isNotEmpty) {
          setStateIfMounted(() {
            posts['data'].addAll(fetchedPosts['data']);
            postLength = posts['data'].length;
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          hasNextPage = false;
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
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Posts',
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
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: postLength,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostDetails(
                                          postDetails: posts['data'][index],
                                        ))),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 2, bottom: 2),
                              child: Container(
                                width: 300,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    gradient: const LinearGradient(
                                      colors: [Colors.black, Colors.black26],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "${posts['data'][index]['image']}"),
                                      fit: BoxFit.cover,
                                    )),
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    gradient: LinearGradient(
                                      colors: [Colors.black87, Colors.black12],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: NetworkImage(
                                                      "${posts['data'][index]['owner']['picture']}"),
                                                  radius: 12),
                                              Text(
                                                " ${posts['data'][index]['owner']['firstName']} ${posts['data'][index]['owner']['lastName']}",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                "assets/like2.png",
                                                height: 15,
                                                width: 15,
                                              ),
                                              Text(
                                                " ${posts['data'][index]['likes']}",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // when the loadMore function is running
                      if (isLoadMoreRunning == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 40),
                          child: Center(
                            child: Container(
                              color: Colors.white10.withOpacity(0.1),
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
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Textn Style for outlines
// Widget nameStyle({String title = ""}) {
//   return Stack(
//     children: <Widget>[
//       Text(
//         title,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//             color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
//       ),
//       Text(
//         title,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             foreground: Paint()
//               ..color = Colors.black
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = 0.5,
//             fontWeight: FontWeight.bold,
//             fontSize: 22),
//       ),
//     ],
//   );
// }

// Widget subtitleStyle({String title = ""}) {
//   return Stack(
//     children: <Widget>[
//       Text(
//         title,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//             color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       Text(
//         title,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             foreground: Paint()
//               ..color = Colors.black
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = 0.5,
//             fontSize: 18,
//             fontWeight: FontWeight.bold),
//       ),
//     ],
//   );
// }
