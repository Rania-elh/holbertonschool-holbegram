import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holbegram/methods/auth_methods.dart';

class AddPicture extends StatefulWidget {
  const AddPicture({
    super.key,
    required this.email,
    required this.password,
    required this.username,
  });

  final String email;
  final String password;
  final String username;

  @override
  State<AddPicture> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  Uint8List? _image;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 28),
            const Text(
              'Holbegram',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 50,
              ),
            ),
            const Image(
              image: AssetImage('assets/images/logo.png'),
              width: 80,
              height: 60,
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.username} Welcome to Holbegram.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose an image from your gallery or take a new one.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _image == null
                ? Image.asset(
                    'assets/images/Sample_User_Icon.png',
                    width: 200,
                    height: 200,
                  )
                : ClipOval(
                    child: Image.memory(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
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
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(218, 226, 37, 24),
                  ),
                ),
                onPressed: () async {
                  String email = widget.email;
                  String username = widget.username;
                  String password = widget.password;
                  String result = await AuthMethode().signUpUser(
                    email: email,
                    username: username,
                    password: password,
                    file: _image,
                  );
                  if (result == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('success')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                },
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
