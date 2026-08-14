import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:holbegram/screens/home.dart';
import 'package:holbegram/screens/pages/methods/post_storage.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  Uint8List? _image;
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  void selectImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _image = bytes;
      });
    }
  }

  void selectImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _image = bytes;
      });
    }
  }

  Future postImage() async {
    if (_image == null) {
      return;
    }
    var user = Provider.of<UserProvider>(context, listen: false).user;
    setState(() {
      _isLoading = true;
    });
    String result = await PostStorage().uploadPost(
      _captionController.text,
      user!.uid,
      user.username,
      user.photoUrl,
      _image!,
    );
    setState(() {
      _isLoading = false;
    });
    if (result == "Ok") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Image',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : postImage,
            child: const Text(
              'Post',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 28,
                color: Color.fromARGB(218, 226, 37, 24),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Add Image',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Choose an image from your gallery or take a new one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _image == null
                      ? Image.asset(
                          'assets/images/Sample_User_Icon.png',
                          width: 220,
                          height: 220,
                        )
                      : Image.memory(
                          _image!,
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.image_outlined,
                          color: Color.fromARGB(218, 226, 37, 24),
                          size: 40,
                        ),
                        onPressed: selectImageFromGallery,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color.fromARGB(218, 226, 37, 24),
                          size: 40,
                        ),
                        onPressed: selectImageFromCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
