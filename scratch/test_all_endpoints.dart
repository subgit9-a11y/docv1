import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print("==================================================");
  print("   ASTRA FULL ENDPOINT CONNECTIVITY TEST");
  print("==================================================");
  print(
      "Note: Since we are not logged in as a doctor, we expect 400 (Bad Request) or 401/403 (Unauthorized).");
  print(
      "If we receive a 404 (Not Found) or 500 (Server Error), that indicates a missing endpoint or crash.\n");

  final client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  Future<void> testEndpoint(String name, String method, String url) async {
    print("Testing: $name");
    print("URL: [$method] $url");
    try {
      final request = method == 'POST'
          ? await client.postUrl(Uri.parse(url))
          : await client.getUrl(Uri.parse(url));

      request.headers.set('User-Agent', 'AstraTestClient/1.0');
      request.headers.set('Content-Type', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      String statusEmoji =
          (response.statusCode >= 200 && response.statusCode < 300)
              ? "✅"
              : (response.statusCode == 400 ||
                      response.statusCode == 401 ||
                      response.statusCode == 403 ||
                      response.statusCode == 422)
                  ? "🔒"
                  : "❌";

      print("Status Code: ${response.statusCode} $statusEmoji");
      print(
          "Data Snippet: ${responseBody.length > 100 ? '${responseBody.substring(0, 100)}...' : responseBody}\n");
    } catch (e) {
      print("Result: ❌ ERROR - $e\n");
    }
  }

  final endpoints = [
    {
      "name": "Auth - Login",
      "method": "POST",
      "url": "https://astra.ayureze.in/api/v1/auth/login"
    },
    {
      "name": "Auth - Get User (Requires Token)",
      "method": "GET",
      "url": "https://astra.ayureze.in/api/v1/auth/user"
    },
    {
      "name": "Doctors - Profile",
      "method": "GET",
      "url": "https://astra.ayureze.in/api/v1/api/doctors/test_id"
    },
    {
      "name": "Patients - Search",
      "method": "GET",
      "url": "https://astra.ayureze.in/api/v1/patients/search/john"
    },
    {
      "name": "Prescriptions - Create",
      "method": "POST",
      "url": "https://astra.ayureze.in/api/v1/api/prescriptions/create"
    },
    {
      "name": "Astra Brain - Chat",
      "method": "POST",
      "url": "https://astra.ayureze.in/api/v1/brain/chat"
    },
    {
      "name": "Shopify - AI Assist",
      "method": "POST",
      "url": "https://astra.ayureze.in/api/v1/shopify/ai-shop-assist"
    },
    {
      "name": "Video - Generate Token",
      "method": "GET",
      "url": "https://astra.ayureze.in/api/v1/video/token?channel=test"
    },
    {
      "name": "Treatment Centers",
      "method": "GET",
      "url":
          "https://astra.ayureze.in/api/v1/api/treatment-centers/nearby/search?latitude=28.6&longitude=77.2"
    },
  ];

  for (var endpoint in endpoints) {
    await testEndpoint(
        endpoint["name"]!, endpoint["method"]!, endpoint["url"]!);
  }

  print("==================================================");
  print("All remaining connectivity tests completed.");
  print("==================================================");
}
