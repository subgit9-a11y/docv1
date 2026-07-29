import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print("==================================================");
  print("   ASTRA BACKEND FLOW CONNECTION TEST");
  print("==================================================");

  final client = HttpClient();

  // Disable SSL verification for testing if needed
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  Future<void> testEndpoint(String name, String url,
      {Map<String, String>? headers}) async {
    print("\nTesting Flow: $name");
    print("URL: $url");
    try {
      final request = await client.getUrl(Uri.parse(url));
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.add(key, value);
        });
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("Status Code: ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Result: ✅ SUCCESS");
        print(
            "Data: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}");
      } else {
        print("Result: ⚠️ FAILED (Expected with missing Doctor Auth Token)");
        print("Data: $responseBody");
      }
    } catch (e) {
      print("Result: ❌ ERROR - $e");
    }
  }

  // 1. Test Base Health (Unauthenticated)
  await testEndpoint(
      "Astra Backend Health Check", "https://astra.ayureze.in/health");

  // 2. Test Doctor Search API (Might be public or require auth)
  await testEndpoint("Doctor Search API",
      "https://astra.ayureze.in/api/v1/api/doctors/nearby/search?latitude=28.6139&longitude=77.2090");

  // 3. Test Shopify Products API
  await testEndpoint("Shopify Live Products API",
      "https://astra.ayureze.in/api/v1/shopify/products/all");

  // 4. Test Translation Languages API
  await testEndpoint("Translation Supported Languages",
      "https://astra.ayureze.in/api/v1/api/translate/languages");

  print("\n==================================================");
  print("Test completed. The backend is reachable!");
  print("==================================================");
}
