import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 5,
              ),
              child: SizedBox(
                height: 54,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasData) {
                    final posts = snapshot.data!.docs;

                    if (posts.isEmpty) {
                      return const Center(
                        child: Text('No images found'),
                      );
                    }

                    return StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index].data();

                        final postUrl = post['postUrl'] as String?;

                        if (postUrl == null || postUrl.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Image.network(
                          postUrl,
                          fit: BoxFit.cover,
                        );
                      },
                      staggeredTileBuilder: (index) {
                        if (index == 0) {
                          return StaggeredTile.count(2, 2);
                        }

                        return StaggeredTile.count(1, 1);
                      },
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
