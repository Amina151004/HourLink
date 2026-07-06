import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dehjs7bd';
  static const String _uploadPreset = 'hourlink';

  static Uri get _uploadUrl =>
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  /// Uploads an image and returns the resulting secure URL, or null on failure.
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', _uploadUrl)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
