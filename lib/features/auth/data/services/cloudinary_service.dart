import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // ── Read from .env instead of hardcoding ──────────────────────────────
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  static String get _uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  static Uri get _uploadUrl =>
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  Future<String?> uploadProfilePicture(File imageFile) async {
    // guard — crash early with a clear message if .env is missing
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw Exception('Cloudinary config missing from .env');
    }

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
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}
