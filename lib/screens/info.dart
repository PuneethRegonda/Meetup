import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
 final Map<String,dynamic> interest;
  InfoScreen(this.interest);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(interest['title']),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(imageUrl: interest['url'].toString().trim(),fit: BoxFit.fitWidth,height: MediaQuery.of(context).size.height*.33,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(interest['title'],style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(interest['content'],style: TextStyle(fontSize: 16.0,),),
            ),
          ],
        ),
      ),
    );
  }
}
