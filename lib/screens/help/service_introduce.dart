import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ServiceIntroduceScreen extends StatefulWidget {
  const ServiceIntroduceScreen({super.key});

  @override
  State<ServiceIntroduceScreen> createState() => _ServiceIntroduceScreenState();
}

class _ServiceIntroduceScreenState extends State<ServiceIntroduceScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHtmlContent();
  }

  Future<void> _loadHtmlContent() async {
    try {
      // HTML 파일을 assets에서 읽기
      final String htmlContent = await rootBundle.loadString(
        'lib/screens/help/service_introduce.html',
      );

      // WebView 컨트롤러 초기화
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        )
        ..loadHtmlString(htmlContent);
    } catch (e) {
      print('HTML 파일 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서비스 소개'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadHtmlContent();
            },
          ),
        ],
      ),
      body: _isLoading || _controller == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller!),
    );
  }
}
