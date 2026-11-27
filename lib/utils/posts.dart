import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/pages/methods/post_storage.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final PostStorage postStorage = PostStorage();

  Future<void> toggleFavorite(String postId, String uid) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid);

    final userSnapshot = await userRef.get();

    final savedPosts = List<String>.from(
      userSnapshot.data()?['saved'] ?? [],
    );

    if (savedPosts.contains(postId)) {
      await userRef.set({
        'saved': FieldValue.arrayRemove([postId]),
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
        'saved': FieldValue.arrayUnion([postId]),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error ${snapshot.error}'),
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var post = data[index].data();
              final postId = post['postId'] as String;

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 540,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                post['profImage'],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(post['username']),
                            const Spacer(),
                            IconButton(
                              onPressed: () async {
                                try {
                                  await postStorage.deletePost(
                                    post['postId'],
                                    post['publicId'] ?? '',
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text('Post Deleted'),
                                    ),
                                  );
                                } catch (error) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(error.toString()),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Text(post['caption']),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            post['postUrl'],
                            width: 350,
                            height: 350,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_border),
                            const SizedBox(width: 15),
                            const Icon(Icons.comment),
                            const SizedBox(width: 15),
                            const Icon(Icons.send),
                            const Spacer(),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(
                                    FirebaseAuth.instance.currentUser?.uid,
                                  )
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                final savedPosts = List<String>.from(
                                  userSnapshot.data
                                          ?.data()?['saved'] ??
                                      [],
                                );

                                final isSaved =
                                    savedPosts.contains(postId);

                                return IconButton(
                                  onPressed: FirebaseAuth
                                              .instance.currentUser ==
                                          null
                                      ? null
                                      : () async {
                                          try {
                                            await toggleFavorite(
                                              postId,
                                              FirebaseAuth.instance
                                                  .currentUser!.uid,
                                            );
                                          } catch (error) {
                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  error.toString(),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  icon: Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
