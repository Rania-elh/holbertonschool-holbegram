import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holbegram/providers/user_provider.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorites",
          style: TextStyle(fontFamily: "Billabong", fontSize: 35),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("posts").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var posts = snapshot.data!.docs.where((doc) {
            return user.saved.contains(doc['postId']);
          }).toList();
          return GridView.builder(
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return Image.network(
                posts[index]['postUrl'],
                fit: BoxFit.cover,
              );
            },
          );
        },
      ),
    );
  }
}
