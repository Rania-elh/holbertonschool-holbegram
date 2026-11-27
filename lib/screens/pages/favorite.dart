import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 35,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Please log in'),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (!userSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final userData = userSnapshot.data!.data();

                final savedPosts = List<String>.from(
                  userData?['saved'] ?? [],
                );

                if (savedPosts.isEmpty) {
                  return const Center(
                    child: Text('No favorite posts'),
                  );
                }

                return StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }

                    if (!postsSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final favoritePosts =
                        postsSnapshot.data!.docs.where((post) {
                      return savedPosts.contains(post.id);
                    }).toList();

                    if (favoritePosts.isEmpty) {
                      return const Center(
                        child: Text('No favorite posts'),
                      );
                    }

                    return ListView.builder(
                      itemCount: favoritePosts.length,
                      itemBuilder: (context, index) {
                        final post = favoritePosts[index].data();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Image.network(
                            post['postUrl'],
                            width: double.infinity,
                            height: 350,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
