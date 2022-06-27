import 'dart:convert';
import 'package:http/http.dart' as http;

String baseUrl = 'https://dummyapi.io/data/v1/';
int page = 1;
int limit = 10;
String appId = "62b2b78d1af170c63fe12335";
String category = 'post';
bool hasNextPage = true;
bool isFirstLoadRunning = false;
bool isLoadMoreRunning = false;
Map posts = {};

class ApiCall {
  firstLoad() async {
    isFirstLoadRunning = true;
    try {
      final res = await http.get(
          Uri.parse("$baseUrl$category?page=$page&limit=$limit}"),
          headers: {"app-id": appId});

      posts = json.decode(res.body);
      print("=======$posts");
      return posts;
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }
    isFirstLoadRunning = false;
  }

  loadMore(scrollController) async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      isLoadMoreRunning = true; // Display a progress indicator at the bottom
      page += 1; // Increase page by 1
      try {
        final res = await http.get(
            Uri.parse("$baseUrl$category?page=$page&limit=$limit"),
            headers: {"app-id": appId});

        final Map fetchedPosts = json.decode(res.body);
        if (fetchedPosts.isNotEmpty) {
          posts.addAll(fetchedPosts);
          return posts;
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request

          hasNextPage = false;
          return posts;
        }
      } catch (err) {
        print("$err");
        print('Something went wrong!');
      }
      isLoadMoreRunning = false;
    }
  }
}
