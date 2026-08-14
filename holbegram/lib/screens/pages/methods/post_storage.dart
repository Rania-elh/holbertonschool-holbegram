import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:holbegram/models/post.dart';
import 'package:holbegram/screens/auth/methods/user_storage.dart';

class PostStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String caption,
    String uid,
    String username,
    String profImage,
    Uint8List image,
  ) async {
    try {
      var imageData = await StorageMethods().uploadImageToCloudinary(
        true,
        "posts",
        image,
      );
      String postId = const Uuid().v1();
      Post post = Post(
        caption: caption,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: imageData['url']!,
        profImage: profImage,
      );
      await _firestore.collection("posts").doc(postId).set({
        "caption": post.caption,
        "uid": post.uid,
        "username": post.username,
        "likes": post.likes,
        "postId": post.postId,
        "datePublished": post.datePublished,
        "postUrl": post.postUrl,
        "profImage": post.profImage,
        "publicId": imageData['publicId'],
      });
      await _firestore.collection("users").doc(uid).update({
        "posts": FieldValue.arrayUnion([postId]),
      });
      return "Ok";
    } catch (e) {
      return e.toString();
    }
  }

  Future deletePost(String postId, String publicId) async {
    await _firestore.collection("posts").doc(postId).delete();
  }

  Future savePost(String userId, String postId) async {
    var userDoc = await _firestore.collection("users").doc(userId).get();
    List saved = userDoc.data()?['saved'] ?? [];
    if (saved.contains(postId)) {
      await _firestore.collection("users").doc(userId).update({
        "saved": FieldValue.arrayRemove([postId]),
      });
    } else {
      await _firestore.collection("users").doc(userId).update({
        "saved": FieldValue.arrayUnion([postId]),
      });
    }
  }
}
