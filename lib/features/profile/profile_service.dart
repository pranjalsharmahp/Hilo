import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileService {
  static Future<String?> uploadProfileImage(
    File imageFile,
    String email,
  ) async {
    final uri = Uri.parse(
      'https://hilo-backend-ozkp.onrender.com/users/profile-picture/$email',
    );

    final request = http.MultipartRequest('POST', uri);

    // The field name must be 'profile'
    final multipartFile = await http.MultipartFile.fromPath(
      'profile', // this must match upload.single('profile')
      imageFile.path,
    );

    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['profile_url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
