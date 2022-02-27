import 'dart:convert';

import 'package:area_de_risco/app/components/my_banner.dart';
import 'package:area_de_risco/app/screens/feed/feed_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class TwitterController extends ChangeNotifier {
  List<dynamic> posts = [];
  var medias = [];

  var id = "93666404";

  var bearer =
      "AAAAAAAAAAAAAAAAAAAAAEpHWgEAAAAAe2S8Wy5y0uAk019CXyri%2FD42Iyo%3DgRv5LmNc7ea1WT61xbLIiuMuxuk9jivTxOLZ88WxYyqwNYmFzJ";

  var image_url;
  TwitterController() {
    init();
  }

  init() async {
    Response response = await get(
        Uri.parse(
            "https://api.twitter.com/2/users/$id/tweets?tweet.fields=created_at,attachments&expansions=author_id,attachments.media_keys&user.fields=profile_image_url,created_at&media.fields=duration_ms,height,media_key,preview_image_url,public_metrics,type,url,width&max_results=100"),
        headers: {
          "authorization":
              "Bearer AAAAAAAAAAAAAAAAAAAAAES3VwEAAAAAZNRb2oQrudG6e2tVjEERZzWSbJM%3DMgTNLHjwTWXKwfr2lfed9XTkWx3Z5DY0QhI7uxItSQAthGMloK"
        });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data['includes']);
      image_url = data['includes']['users'][0]['profile_image_url'];
      var index = 0;
      for (var d in data['data']) {
        index++;
        posts.add(d);
        if (index == 5) {
          posts.add(MyBanner());
          index = 0;
        }
      }
      //posts.addAll(data['data']);
      if (data['includes']['media'] != null)
        medias.addAll(data['includes']['media']);
      notifyListeners();
    }
    print(posts);
  }
}
