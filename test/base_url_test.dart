import 'dart:io';

import 'package:doctro/network/apis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Check pattern of baseUrl in Apis',
    () {
      expect(Apis.baseUrl, 'https://astra.ayureze.in/api/v1/');
    },
  );

  test(
    'network_api.g.dart file exists',
    () {
      var filePath = 'lib/network/network_api.g.dart';

      // Check if the file exists
      expect(File(filePath).existsSync(), isTrue,
          reason: 'network_api.g.dart file does not exist/\n'
              'Please run the command: flutter pub run build_runner build --delete-conflicting-outputs');
    },
  );
}
