import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthMethode {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill all the fields';
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    }
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    Uint8List? file,
  }) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return 'Please fill all the fields';
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user == null) {
        return 'Unable to create user';
      }

      Users users = Users(
        uid: user.uid,
        email: email,
        username: username,
        bio: '',
        photoUrl: '',
        followers: [],
        following: [],
        posts: [],
        saved: [],
        searchKey: username.toLowerCase(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(users.toJson());

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed';
    }
  }

  Future<Users> getUserDetails() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is connected');
    }

    DocumentSnapshot userSnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userSnapshot.exists && userSnapshot.data() != null) {
      return Users.fromSnap(userSnapshot);
    }

    String email = currentUser.email ?? '';
    String username = currentUser.displayName ??
        (email.contains('@') ? email.split('@').first : 'user');

    Users users = Users(
      uid: currentUser.uid,
      email: email,
      username: username,
      bio: '',
      photoUrl: currentUser.photoURL ?? '',
      followers: [],
      following: [],
      posts: [],
      saved: [],
      searchKey: username.toLowerCase(),
    );

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .set(users.toJson());

    return users;
  }
}
