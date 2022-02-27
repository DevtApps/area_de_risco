import 'dart:convert';

import 'package:area_de_risco/app/components/my_banner.dart';
import 'package:area_de_risco/app/controllers/twitter_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:tweet_ui/compact_tweet_view.dart';
import 'package:tweet_ui/embedded_tweet_view.dart';
import 'package:tweet_ui/models/api/tweet.dart';
import 'package:tweet_ui/tweet_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TwitterController>(builder: (c, twitterController, child) {
      return ListView.builder(
        itemBuilder: (c, i) {
          if (twitterController.posts[i] is MyBanner) {
            return twitterController.posts[i];
          }
          var tweet = twitterController.posts[i];
          var foto;
          if (tweet['attachments'] != null &&
              tweet['attachments']['media_keys'] != null) {
            print(twitterController.medias);
            var media = twitterController.medias.where((element) =>
                element['media_key'] == tweet['attachments']['media_keys'][0] &&
                element['type'] == "photo");
            if (media.isNotEmpty) foto = media.first['url'];
          }
          return Card(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(twitterController.image_url),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: Column(
                        children: [
                          Container(
                            child: Text(tweet['text']),
                          ),
                          foto != null
                              ? Container(
                                  margin: EdgeInsets.all(8),
                                  child: Image.network(
                                    foto,
                                    loadingBuilder: (c, child, loading) {
                                      if (loading != null)
                                        // ignore: curly_braces_in_flow_control_structures
                                        return Center(
                                            child: CircularProgressIndicator(
                                          value:
                                              (loading.cumulativeBytesLoaded *
                                                  100 /
                                                  loading.expectedTotalBytes!),
                                        ));
                                      else
                                        return child;
                                    },
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        itemCount: twitterController.posts.length,
      );
    });
  }
}
