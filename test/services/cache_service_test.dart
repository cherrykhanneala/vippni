import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vipnni/services/logging_service.dart';
import 'package:vipnni/services/cache_service.dart';
import 'dart:convert';

// Generate the mock classes
@GenerateMocks([SharedPreferences, LoggingService])
import 'cache_service_test.mocks.dart';

void main() {
  late CacheService cacheService;
  late MockSharedPreferences mockPrefs;
  late MockLoggingService mockLogger;

  setUp(() async {
    mockPrefs = MockSharedPreferences();
    mockLogger = MockLoggingService();
    
    cacheService = CacheService();
    cacheService.setDependencies(mockPrefs, mockLogger);
  });

  group('CacheService', () {
    group('cacheData', () {
      test('should store data with timestamp and expiry', () async {
        // Using argThat with matchers instead of any<String>()
        when(mockPrefs.setString(
          argThat(isA<String>()), 
          argThat(isA<String>())
        )).thenAnswer((_) => Future.value(true));
        
        final result = await cacheService.cacheData(
          'test_key',
          {'name': 'Product 1'},
          expiry: const Duration(hours: 1),
        );
        
        verify(mockPrefs.setString(
          'test_key',
          argThat(contains('"data":{"name":"Product 1"}')),
        )).called(1);
        
        expect(result, true);
      });
      
      test('should handle exceptions', () async {
        when(mockPrefs.setString(
          argThat(isA<String>()), 
          argThat(isA<String>())
        )).thenThrow(Exception('Test exception'));
        
        final result = await cacheService.cacheData(
          'test_key',
          {'name': 'Product 1'},
        );
        
        verify(mockLogger.error(argThat(isA<String>()), any)).called(1);
        expect(result, false);
      });
    });
    
    group('getCachedData', () {
      test('should return null for non-existent key', () async {
        when(mockPrefs.getString('non_existent_key')).thenReturn(null);
        
        final result = await cacheService.getCachedData('non_existent_key');
        
        expect(result, null);
      });
      
      test('should return data for valid non-expired entry', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final cacheEntry = {
          'data': {'name': 'Product 1'},
          'timestamp': now - 1000, // 1 second ago
          'expiry': 3600000, // 1 hour in milliseconds
        };
        
        when(mockPrefs.getString('test_key')).thenReturn(jsonEncode(cacheEntry));
        
        final data = await cacheService.getCachedData('test_key');
        
        expect(data, {'name': 'Product 1'});
      });
      
      test('should return null and remove expired entries', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final cacheEntry = {
          'data': {'name': 'Product 1'},
          'timestamp': now - 3700000, // 1 hour and 10 minutes ago
          'expiry': 3600000, // 1 hour in milliseconds
        };
        
        when(mockPrefs.getString('test_key')).thenReturn(jsonEncode(cacheEntry));
        when(mockPrefs.remove('test_key')).thenAnswer((_) => Future.value(true));
        
        final data = await cacheService.getCachedData('test_key');
        
        verify(mockPrefs.remove('test_key')).called(1);
        expect(data, null);
      });
      
      test('should handle exceptions', () async {
        when(mockPrefs.getString('test_key')).thenThrow(Exception('Test exception'));
        
        final result = await cacheService.getCachedData('test_key');
        
        verify(mockLogger.error(argThat(isA<String>()), any)).called(1);
        expect(result, null);
      });
    });
    
    group('clearCache', () {
      test('should remove specific cache entry', () async {
        when(mockPrefs.remove('test_key')).thenAnswer((_) => Future.value(true));
        
        final result = await cacheService.clearCache('test_key');
        
        verify(mockPrefs.remove('test_key')).called(1);
        expect(result, true);
      });
      
      test('should handle exceptions', () async {
        when(mockPrefs.remove('test_key')).thenThrow(Exception('Test exception'));
        
        final result = await cacheService.clearCache('test_key');
        
        verify(mockLogger.error(argThat(isA<String>()), any)).called(1);
        expect(result, false);
      });
    });
    
    group('clearAllCache', () {
      test('should clear all cache entries', () async {
        when(mockPrefs.clear()).thenAnswer((_) => Future.value(true));
        
        final result = await cacheService.clearAllCache();
        
        verify(mockPrefs.clear()).called(1);
        expect(result, true);
      });
      
      test('should handle exceptions', () async {
        when(mockPrefs.clear()).thenThrow(Exception('Test exception'));
        
        final result = await cacheService.clearAllCache();
        
        verify(mockLogger.error(argThat(isA<String>()), any)).called(1);
        expect(result, false);
      });
    });
    
    group('clearCacheByPattern', () {
      test('should remove matching keys', () async {
        when(mockPrefs.getKeys()).thenReturn(Set<String>.from([
          'products_123', 
          'products_456', 
          'user_789'
        ]));
        
        when(mockPrefs.remove(argThat(isA<String>()))).thenAnswer((_) => Future.value(true));
        
        await cacheService.clearCacheByPattern('products_');
        
        verify(mockPrefs.remove('products_123')).called(1);
        verify(mockPrefs.remove('products_456')).called(1);
        verifyNever(mockPrefs.remove('user_789'));
      });
      
      test('should handle exceptions', () async {
        when(mockPrefs.getKeys()).thenThrow(Exception('Test exception'));
        
        await cacheService.clearCacheByPattern('products_');
        
        verify(mockLogger.error(argThat(isA<String>()), any)).called(1);
      });
    });
  });
}