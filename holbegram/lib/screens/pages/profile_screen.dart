import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holbegram/methods/auth_methods.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:holbegram/screens/login_screen.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
        title: Text(
          user.username,
          style: const TextStyle(fontFamily: "Billabong", fontSize: 32),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthMethode().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    emailController: TextEditingController(),
                    passwordController: TextEditingController(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.photoUrl != ""
                      ? NetworkImage(user.photoUrl)
                      : const AssetImage("assets/images/Sample_User_Icon.png")
                          as ImageProvider,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "${user.posts.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text("Posts"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${user.followers.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text("Followers"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${user.following.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text("Following"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(user.bio),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("uid", isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var posts = snapshot.data!.docs;
                return GridView.builder(
                  itemCount: posts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
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
          ),
        ],
      ),
    );
  }
}
