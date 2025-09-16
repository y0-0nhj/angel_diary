import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class PhotoshopApiService {
  final String _clientId = dotenv.env['ADOBE_CLIENT_ID']!;
  final String _clientSecret = dotenv.env['ADOBE_CLIENT_SECRET']!;
  final String _endpoint = 'https://image.adobe.io/v1/cutout';

  Future<String?> _getAccessToken() async {
    try {
      final authUrl = Uri.parse('https://ims-na1.adobelogin.com/ims/token/v3');
      final response = await http.post(
        authUrl,
        body: {
          'grant_type': 'client_credentials',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'scope': 'openid,AdobeID,read_organizations',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['access_token'];
      }
      print("토큰 발급 실패: ${response.body}");
      return null;
    } catch (e) {
      print("토큰 발급 에러: $e");
      return null;
    }
  }

  Future<Uint8List?> removeBackground(File imageFile) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return null;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_endpoint));
      request.headers['x-api-key'] = _clientId;
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        print("배경 제거 성공!");
        return await streamedResponse.stream.toBytes();
      } else {
        print("배경 제거 실패: ${await streamedResponse.stream.bytesToString()}");
        return null;
      }
    } catch (e) {
      print("배경 제거 에러: $e");
      return null;
    }
  }
}