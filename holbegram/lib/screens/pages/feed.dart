import 'package:flutter/material.dart';
import 'package:holbegram/utils/posts.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Holbegram',
              style: TextStyle(fontFamily: 'Billabong', fontSize: 35),
            ),
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 40,
              height: 40,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_outline),
          ),
        ],
      ),
      body: Posts(),
    );
  }
}
