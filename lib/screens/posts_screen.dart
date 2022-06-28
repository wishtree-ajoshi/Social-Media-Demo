import 'package:ajoshi_socialmedia_demo/api_call/api_call.dart';
import 'package:ajoshi_socialmedia_demo/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late ScrollController scrollController;
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  int postLength = 0;
  int page = 1;
  int limit = 10;
  Map posts = {};

  @override
  void initState() {
    scrollController = ScrollController()..addListener(loadMoreData);
    firstTimeLoad();
    super.initState();
  }

  void firstTimeLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    final res = await ApiCall().postsPage(page, limit);
    setState(() {
      posts = jsonDecode(res.body);
      postLength = posts['data'].length;
    });
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
        final res = await ApiCall().postsPage(page, limit);
        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts.isNotEmpty) {
          setState(() {
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
          'Posts',
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
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: postLength,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 2, bottom: 2),
                      child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            image: DecorationImage(
                              image: NetworkImage(
                                  "${posts['data'][index]['image']}"),
                              fit: BoxFit.cover,
                            )),
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          decoration: const BoxDecoration(
                              color: Colors.white60,
                              gradient: LinearGradient(
                                colors: [Colors.white60, Colors.white10],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              backgroundBlendMode: BlendMode.lighten),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                nameStyle(
                                    title:
                                        "${posts['data'][index]['owner']['firstName']} ${posts['data'][index]['owner']['lastName']}"),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/like2.png",
                                      height: 15,
                                      width: 15,
                                    ),
                                    subtitleStyle(
                                        title:
                                            " ${posts['data'][index]['likes']}"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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

Widget nameStyle({String title = ""}) {
  return Stack(
    children: <Widget>[
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            foreground: Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
            fontWeight: FontWeight.bold,
            fontSize: 22),
      ),
    ],
  );
}

Widget subtitleStyle({String title = ""}) {
  return Stack(
    children: <Widget>[
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            foreground: Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    ],
  );
}
