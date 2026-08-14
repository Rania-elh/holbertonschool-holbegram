import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.all(8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs.where((doc) {
            final query = _searchController.text.toLowerCase();
            if (query.isEmpty) return true;
            final username = (doc['username'] ?? '').toString().toLowerCase();
            final caption = (doc['caption'] ?? '').toString().toLowerCase();
            return username.contains(query) || caption.contains(query);
          }).toList();

          return SingleChildScrollView(
            child: StaggeredGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: List.generate(posts.length, (index) {
                return StaggeredGridTile.count(
                  crossAxisCellCount: (index % 7 == 0) ? 2 : 1,
                  mainAxisCellCount: (index % 7 == 0) ? 2 : 1,
                  child: Image.network(
                    posts[index]['postUrl'] ?? '',
                    fit: BoxFit.cover,
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
