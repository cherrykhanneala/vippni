import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vipnni/services/cache_service.dart';
import 'package:vipnni/services/logging_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockLoggingService extends Mock implements LoggingService {}

void main() {
  test('hello world!', () {
    expect(1 + 1, 2);
  });
}