import 'dart:io';
import 'package:http/http.dart' as http;

String baseUrl = 'https://dummyapi.io/data/v1/';
String appId = "62b2b78d1af170c63fe12335";

class ApiCall {
  Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  Future postsPage(int page, int limit) async {
    try {
      final res = await http.get(
          Uri.parse("${baseUrl}post?page=$page&limit=$limit}"),
          headers: {"app-id": appId});
      return res;
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }
  }

  Future usersList(int page, int limit) async {
    try {
      final res = await http.get(
          Uri.parse("${baseUrl}user?page=$page&limit=$limit}"),
          headers: {"app-id": appId});
      return res;
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }
  }

  Future userProfile(int page, int limit, String userId) async {
    try {
      if (userId == '') {
        userId = '60d0fe4f5311236168a109d0';
      }
      try {
        final res = await http.get(Uri.parse("${baseUrl}user/$userId"),
            headers: {"app-id": appId});
        return res;
      } catch (e) {
        print(e);
      }
    } catch (err) {
      print('Something went wrong');
    }
  }

  Future userPosts(int page, int limit, String userId) async {
    try {
      if (userId == '') {
        userId = '60d0fe4f5311236168a109d0';
      }
      final res = await http.get(
          Uri.parse("${baseUrl}user/$userId/post?page=$page&limit=$limit"),
          headers: {"app-id": appId});
      return res;
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }
  }

  Future postComments(int page, int limit, String userId) async {
    try {
      if (userId == '') {
        userId = '60d0fe4f5311236168a109d0';
      }
      final res = await http.get(
          Uri.parse("${baseUrl}post/$userId/comment?page=$page&limit=$limit"),
          headers: {"app-id": appId});
      return res;
    } catch (err) {
      print("$err");
      print('Something went wrong');
    }
  }
}
