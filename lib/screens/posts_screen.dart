import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostsScreen extends StatefulWidget {
  Map posts;
  Color primaryColor;
  String baseUrl = '';
  int page;
  int limit = 0;
  String appId = "";
  String category = '';
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;

  PostsScreen(
      {Key? key,
      required this.posts,
      required this.primaryColor,
      required this.page,
      required this.limit,
      required this.appId,
      required this.category,
      required this.hasNextPage,
      required this.baseUrl,
      required this.isFirstLoadRunning,
      required this.isLoadMoreRunning})
      : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController()..addListener(loadMore);
    firstLoad();
    super.initState();
  }

  void firstLoad() async {
    setState(() {
      widget.isFirstLoadRunning = true;
    });
    try {
      final res = await http.get(
          Uri.parse(
              "${widget.baseUrl}${widget.category}?page=${widget.page}&limit=${widget.limit}}"),
          headers: {"app-id": widget.appId});
      setState(() {
        widget.posts = json.decode(res.body);
        print("=======${widget.posts}");
      });
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }

    setState(() {
      widget.isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    if (widget.hasNextPage == true &&
        widget.isFirstLoadRunning == false &&
        widget.isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      setState(() {
        widget.isLoadMoreRunning =
            true; // Display a progress indicator at the bottom
      });
      widget.page += 1; // Increase page by 1
      try {
        final res = await http.get(
            Uri.parse(
                "${widget.baseUrl}${widget.category}?page=${widget.page}&limit=${widget.limit}"),
            headers: {"app-id": widget.appId});

        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            widget.posts.addAll(fetchedPosts);
            //print("=======${widget.posts}");
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            widget.hasNextPage = false;
          });
        }
      } catch (err) {
        print("$err");
        print('Something went wrong!');
      }

      setState(() {
        widget.isLoadMoreRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: widget.primaryColor,
        title: const Text(
          'Posts',
          style: TextStyle(
            color: Colors.black,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: widget.isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.posts['data']!.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 15,
                      color: widget.primaryColor,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image(
                            image: NetworkImage(
                                "${widget.posts['data'][index]['image']}"),
                            fit: BoxFit.fitWidth,
                            height: 300,
                            width: 400,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Text(
                                    "${widget.posts['data'][index]['owner']['firstName']}"),
                                Text("${widget.posts['data'][index]['likes']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // when the loadMore function is running
                if (widget.isLoadMoreRunning == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    // ignore: unnecessary_const
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // When nothing else to load
                if (widget.hasNextPage == false)
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
