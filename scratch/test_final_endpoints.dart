import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print("==================================================");
  print("   FINAL ASTRA ENDPOINT VERIFICATION TEST");
  print("==================================================");

  final client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  Future<void> testEndpoint(String name, String method, String url,
      {Map<String, String>? headers}) async {
    print("Testing: $name");
    print("URL: [$method] $url");
    try {
      final request = method == 'POST'
          ? await client.postUrl(Uri.parse(url))
          : await client.getUrl(Uri.parse(url));

      request.headers.set('User-Agent', 'AstraTestClient/1.0');
      request.headers.set('Content-Type', 'application/json');

      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.add(key, value);
        });
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("Status Code: ${response.statusCode}");
      print("Response: $responseBody\n");
    } catch (e) {
      print("Result: ❌ ERROR - $e\n");
    }
  }

  // 1. Test Auth Login Endpoint
  // Note: We don't have a real Firebase Token, so we send a dummy one to see if it triggers the 401 instead of 404!
  await testEndpoint("Astra Auth Login (With Dummy Token)", "POST",
      "https://astra.ayureze.in/api/v1/auth/login",
      headers: {"Authorization": "Bearer fake_token_123"});

  // 2. Test Video Token Endpoint
  await testEndpoint("Agora Video Token Generator", "GET",
      "https://astra.ayureze.in/api/v1/video/token?channel=test_room_123");

  print("==================================================");
  print("Test completed.");
  print("==================================================");
}
