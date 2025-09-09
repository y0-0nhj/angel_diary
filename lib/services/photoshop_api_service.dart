import 'dart:io';
import 'dart:typed_data'; // Uint8List를 사용하기 위해 import
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class PhotoshopApiService {
  final String _clientId = dotenv.env['ADOBE_CLIENT_ID']!;
  final String _clientSecret = dotenv.env['ADOBE_CLIENT_SECRET']!;
  final String _endpoint = 'https://image.adobe.io/v1/cutout'; // 배경 제거 API 엔드포인트



  // ✨ 1단계: Access Token을 받아오는 함수 (완성된 코드)
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
        final jsonResponse = jsonDecode(response.body);
        final accessToken = jsonResponse['access_token'];
        print("액세스 토큰 발급 성공!");
        return accessToken;
      } else {
        print("액세스 토큰 발급 실패 (상태 코드: ${response.statusCode})");
        print("오류 내용: ${response.body}");
        return null;
      }
    } catch (e) {
      print("액세스 토큰 발급 중 예외 발생: $e");
      return null;
    }
  }





  // 이미지를 받아서 배경이 제거된 이미지 데이터(Uint8List)를 반환하는 함수
  Future<Uint8List?> removeBackground(File imageFile) async {
    print("Adobe API로 배경 제거를 시작합니다...");
    try {
      // 1. 요청(Request) 만들기
      var request = http.MultipartRequest('POST', Uri.parse(_endpoint));
      
      // 2. 헤더(Header) 설정
      // Adobe API는 x-api-key와 Authorization 헤더가 모두 필요해
      request.headers['x-api-key'] = _clientId;
      request.headers['Authorization'] = 'Bearer $_clientSecret';

      // 3. 이미지 파일 첨부하기
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // API가 요구하는 필드 이름
          imageFile.path,
        ),
      );

      // 4. 요청 보내고 응답 받기
      var streamedResponse = await request.send();

      // 5. 응답 결과 확인
      if (streamedResponse.statusCode == 200) {
        print("배경 제거 성공! (상태 코드: 200)");
        // 성공 시, 응답받은 이미지 데이터를 바이트 형태로 반환
        return await streamedResponse.stream.toBytes();
      } else {
        // 실패 시, 오류 메시지 출력
        print("배경 제거 실패 (상태 코드: ${streamedResponse.statusCode})");
        print("오류 내용: ${await streamedResponse.stream.bytesToString()}");
        return null;
      }
    } catch (e) {
      print("API 호출 중 예외 발생: $e");
      return null;
    }
  }
}