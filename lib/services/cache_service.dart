import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/logging_service.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  
  final LoggingService _logger = LoggingService();
  SharedPreferences? _prefs;
  
  CacheService._internal();
  
  // For testing purposes
  void setDependencies(SharedPreferences prefs, LoggingService logger) {
    _prefs = prefs;
    // We can't reassign to _logger since it's final, but in tests we'll mock the methods
  }
  
  Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      _logger.info('Cache service initialized');
    }
  }
  
  // Cache data with optional expiry time
  Future<bool> cacheData(String key, dynamic data, {Duration? expiry}) async {
    if (_prefs == null) await init();
    
    try {
      // Convert data to JSON-serializable format
      dynamic serializedData = _serializeData(data);
      
      final Map<String, dynamic> cacheEntry = {
        'data': serializedData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds,
      };
      
      final String jsonData = jsonEncode(cacheEntry);
      final bool result = await _prefs!.setString(key, jsonData);
      
      if (result) {
        _logger.debug('Data cached for key: $key');
      } else {
        _logger.warn('Failed to cache data for key: $key');
      }
      
      return result;
    } catch (e) {
      _logger.error('Error caching data for key $key: $e');
      return false;
    }
  }
  
  // Helper method to make data JSON-serializable
  dynamic _serializeData(dynamic data) {
    if (data == null) {
      return null;
    }
    
    // Handle Timestamp objects
    if (data.runtimeType.toString().contains('Timestamp')) {
      // Convert Timestamp to milliseconds since epoch
      return data.toDate().millisecondsSinceEpoch;
    }
    
    // Handle maps (recursively process all entries)
    if (data is Map) {
      return data.map((key, value) => MapEntry(key, _serializeData(value)));
    }
    
    // Handle lists (recursively process all items)
    if (data is List) {
      return data.map((item) => _serializeData(item)).toList();
    }
    
    // Return other types as is
    return data;
  }
  
  // Retrieve cached data if not expired
  Future<dynamic> getCachedData(String key) async {
    if (_prefs == null) await init();
    
    try {
      final String? jsonData = _prefs!.getString(key);
      if (jsonData == null) {
        _logger.debug('No cached data found for key: $key');
        return null;
      }
      
      final Map<String, dynamic> cacheEntry = jsonDecode(jsonData);
      final int timestamp = cacheEntry['timestamp'];
      final int? expiryMs = cacheEntry['expiry'];
      
      if (expiryMs != null) {
        final int now = DateTime.now().millisecondsSinceEpoch;
        final int expiryTime = timestamp + expiryMs;
        
        if (now > expiryTime) {
          _logger.debug('Cache expired for key: $key');
          await _prefs!.remove(key);
          return null;
        }
      }
      
      _logger.debug('Retrieved cached data for key: $key');
      return cacheEntry['data'];
    } catch (e) {
      _logger.error('Error retrieving cached data for key $key: $e');
      return null;
    }
  }
  
  // Clear specific cache entry
  Future<bool> clearCache(String key) async {
    if (_prefs == null) await init();
    
    try {
      final bool result = await _prefs!.remove(key);
      _logger.debug('Cleared cache for key: $key');
      return result;
    } catch (e) {
      _logger.error('Error clearing cache for key $key: $e');
      return false;
    }
  }
  
  // Clear all cache entries
  Future<bool> clearAllCache() async {
    if (_prefs == null) await init();
    
    try {
      final bool result = await _prefs!.clear();
      _logger.info('Cleared all cache');
      return result;
    } catch (e) {
      _logger.error('Error clearing all cache: $e');
      return false;
    }
  }
  
  // Clear cache entries by pattern
  Future<void> clearCacheByPattern(String pattern) async {
    if (_prefs == null) await init();
    
    try {
      final Set<String> keys = _prefs!.getKeys();
      final Iterable<String> matchingKeys = keys.where(
        (key) => key.contains(pattern)
      );
      
      for (final key in matchingKeys) {
        await _prefs!.remove(key);
      }
      
      _logger.debug('Cleared ${matchingKeys.length} cache entries matching pattern: $pattern');
    } catch (e) {
      _logger.error('Error clearing cache by pattern $pattern: $e');
    }
  }
}