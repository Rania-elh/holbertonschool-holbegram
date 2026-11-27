import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../methods/auth_methods.dart';
import '../home.dart';
import 'methods/post_storage.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  Uint8List? _image;
  final TextEditingController _captionController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> selectImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);

    if (file != null) {
      final imageBytes = await file.readAsBytes();

      setState(() {
        _image = imageBytes;
      });
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
              ),
              ListTile(
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadPost() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose an image'),
        ),
      );
      return;
    }

    try {
      final user = await AuthMethode().getUserDetails();

      final result = await PostStorage().uploadPost(
        _captionController.text,
        user.uid,
        user.username,
        user.photoUrl,
        _image!,
      );

      if (result == 'Ok') {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Image',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: uploadPost,
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'Billabong',
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Add Image',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose an image from your gallery or take a one.',
            style: TextStyle(fontSize: 14),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 45),
          GestureDetector(
            onTap: showImageOptions,
            child: Container(
              width: 205,
              height: 205,
              color: const Color(0xFFF0F0F0),
              child: _image == null
                  ? Image.asset(
                      'assets/images/add.png',
                      fit: BoxFit.contain,
                    )
                  : Image.memory(
                      _image!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
