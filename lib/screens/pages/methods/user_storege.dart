import 'dart:typed_data';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class StorageMethods {
  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/l5uzocgv/image/upload';

  final String cloudinaryPreset = 'zvgs2esb';

  Future<String> uploadImageToCloudinary(
    bool isPost,
    String childName,
    Uint8List file,
  ) async {
    String uniqueId = const Uuid().v1();

    var uri = Uri.parse(cloudinaryUrl);
    var request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = cloudinaryPreset;
    request.fields['folder'] = childName;
    request.fields['public_id'] = uniqueId;

    if (isPost) {
      request.fields['tags'] = 'posts';
    }

    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      file,
      filename: '$uniqueId.jpg',
    );

    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var jsonResponse =
          jsonDecode(String.fromCharCodes(responseData));

      return jsonResponse['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }
}
