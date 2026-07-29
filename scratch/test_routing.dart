import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  Future<void> testEndpoint(String url) async {
    try {
      final request = await client.postUrl(Uri.parse(url));
      final response = await request.close();
      print("$url -> ${response.statusCode}");
    } catch (e) {
      print("$url -> ERROR");
    }
  }

  await testEndpoint("https://astra.ayureze.in/auth/login");
  await testEndpoint("https://astra.ayureze.in/api/auth/login");
  await testEndpoint("https://astra.ayureze.in/video/token");
}
