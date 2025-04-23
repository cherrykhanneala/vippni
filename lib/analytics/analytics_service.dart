import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Log screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
    await _trackLocalAnalytics('screen_view', {'screen_name': screenName});
  }
  
  // Log event
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters.cast<String, Object>());
    await _trackLocalAnalytics(name, parameters);
  }
  
  // Track analytics locally for offline access
  Future<void> _trackLocalAnalytics(String eventName, Map<String, dynamic> parameters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing events or create new list
      List<dynamic> events = [];
      final storedEvents = prefs.getString('local_analytics');
      if (storedEvents != null) {
        events = jsonDecode(storedEvents);
      }
      
      // Add new event with timestamp
      events.add({
        'event': eventName,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Limit stored events to prevent excessive storage use
      if (events.length > 1000) {
        events = events.sublist(events.length - 1000);
      }
      
      // Save updated events
      await prefs.setString('local_analytics', jsonEncode(events));
    } catch (e) {
      print('Error storing local analytics: $e');
    }
  }
  
  // Get local analytics data
  Future<List<Map<String, dynamic>>> getLocalAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEvents = prefs.getString('local_analytics');
      if (storedEvents != null) {
        final events = jsonDecode(storedEvents) as List;
        return events.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error retrieving local analytics: $e');
      return [];
    }
  }
  
  // Get order analytics summary
  Future<Map<String, dynamic>> getOrderAnalyticsSummary() async {
    final events = await getLocalAnalytics();
    
    // Filter order-related events
    final orderEvents = events.where((event) {
      final eventName = event['event'];
      return eventName == 'orders_loaded' || 
             eventName == 'view_order_details' ||
             eventName == 'order_status_changed';
    }).toList();
    
    // Calculate metrics
    int totalOrderViews = 0;
    int totalStatusChanges = 0;
    Map<String, int> statusChangeCount = {};
    
    for (var event in orderEvents) {
      final eventName = event['event'];
      
      if (eventName == 'view_order_details') {
        totalOrderViews++;
      } else if (eventName == 'order_status_changed') {
        totalStatusChanges++;
        final newStatus = event['parameters']['new_status'];
        statusChangeCount[newStatus] = (statusChangeCount[newStatus] ?? 0) + 1;
      }
    }
    
    return {
      'totalOrderViews': totalOrderViews,
      'totalStatusChanges': totalStatusChanges,
      'statusChangeCount': statusChangeCount,
    };
  }
}
