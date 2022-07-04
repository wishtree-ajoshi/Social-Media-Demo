import 'dart:convert';

import 'package:ajoshi_socialmedia_demo/api_call/api_call.dart';
import 'package:ajoshi_socialmedia_demo/main.dart';
import 'package:ajoshi_socialmedia_demo/screens/main_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/posts_screen.dart';
import 'package:ajoshi_socialmedia_demo/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;

class PostDetails extends StatefulWidget {
  Map postDetails;

  PostDetails({Key? key, required this.postDetails}) : super(key: key);

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  late ScrollController scrollController;
  int postsLength = 0;
  int commentLength = 0;
  String dateAdded = '';
  bool hasComment = false;
  int page = 0;
  int limit = 5;
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  Map comments = {};
  bool loadMoreComments = false;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void checkInternetConnection() async {
    internetConnection = await ApiCall().checkUserConnection();
    if (internetConnection == true && comments.isEmpty) {
      loadComments();
    }
  }

  void loadMoreData() async {
    if (hasNextPage == true &&
        internetConnection == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        loadMoreComments == true &&
        scrollController.position.extentAfter < 300) {
      setStateIfMounted(() {
        isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      page += 1; // Increase page by 1
      try {
        final res =
            await ApiCall().userPosts(page, limit, widget.postDetails['id']);
        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts['data'].isNotEmpty) {
          setStateIfMounted(() {
            comments['data'].addAll(fetchedPosts['data']);
            commentLength = comments['data'].length;
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

  void loadComments() async {
    setStateIfMounted(() {
      isFirstLoadRunning = true;
    });

    try {
      if (widget.postDetails['id'] == '') {
        widget.postDetails['id'] = '60d0fe4f5311236168a109d0';
      }
      final res =
          await ApiCall().postComments(page, limit, widget.postDetails['id']);
      setStateIfMounted(() {
        comments = json.decode(res.body);
        commentLength = comments['data'].length;
        if (comments['data'].isNotEmpty) {
          hasComment = true;
        }
      });
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }

    setStateIfMounted(() {
      isFirstLoadRunning = false;
    });
  }

  String month(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      default:
        return 'December';
    }
  }

  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      if (diff.inDays <= 5) {
        return '${diff.inDays} days ago';
      } else if (diff.inDays <= 366) {
        return '${DateTime.parse(widget.postDetails['publishDate']).day}, ${DateTime.parse(widget.postDetails['publishDate']).month}';
      } else {
        return '${DateTime.parse(widget.postDetails['publishDate']).day}, ${month(DateTime.parse(widget.postDetails['publishDate']).month)} ${DateTime.parse(widget.postDetails['publishDate']).year}';
      }
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} secs ago';
    } else {
      return 'just now';
    }
  }

  @override
  void initState() {
    checkInternetConnection();
    tz.initializeTimeZones();
    scrollController = ScrollController()..addListener(loadMoreData);
    dateAdded = convertToAgo(DateTime.parse(widget.postDetails['publishDate']));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: primaryColor,
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
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UserProfile(
                                                    userProfile:
                                                        widget.postDetails,
                                                    userId: widget.postDetails[
                                                        'owner']['id'],
                                                  ))),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 15,
                                                right: 5,
                                                bottom: 10),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  "${widget.postDetails['owner']['picture']}"),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 5, bottom: 10),
                                            child: Text(
                                              "${widget.postDetails['owner']['firstName']} ${widget.postDetails['owner']['lastName']}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.more_vert_rounded),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        style: BorderStyle.solid,
                                        color: Colors.black12,
                                        width: 1.5)),
                                child: Image(
                                  image: NetworkImage(
                                      "${widget.postDetails['image']}"),
                                  fit: BoxFit.fitHeight,
                                  height: 300,
                                  width: double.infinity,
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 20),
                                    child: Image.asset(
                                      "assets/like_outline.png",
                                      alignment: Alignment.centerLeft,
                                      height: 28,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10),
                                    child: Image.asset(
                                      "assets/comment.png",
                                      alignment: Alignment.centerLeft,
                                      height: 35,
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 5),
                                child: Text(
                                  "${widget.postDetails['likes']} likes",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 5),
                                child: Text(
                                  "${widget.postDetails['text']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 5),
                                child: Row(
                                  children: [
                                    for (int i = 0;
                                        i < widget.postDetails['tags'].length;
                                        i++)
                                      Text(
                                        "#${widget.postDetails['tags'][i]} ",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue.shade900),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 5),
                                child: Text(
                                  dateAdded,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 5),
                                child: loadMoreComments
                                    ? hasComment
                                        ? ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: commentLength,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) =>
                                                Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${comments['data'][index]['owner']['firstName']} ${comments['data'][index]['owner']['lastName']}:  ",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "${comments['data'][index]['message']}",
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const Text("No Comments Yet",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black))
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              loadMoreComments = true;
                                            });
                                          },
                                          child: const Text(
                                            "Load Comments",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blueGrey,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
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
}
