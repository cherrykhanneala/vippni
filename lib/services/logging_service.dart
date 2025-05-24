import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:developer' as developer;

enum LogLevel {
  debug,
  info,
  warn,
  error,
  fatal,
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  
  final Logger _logger = Logger('VIPNNI');
  bool _isInitialized = false;
  
  LoggingService._internal();
  
  void initialize() {
    if (_isInitialized) return;
    
    // Set up logging level based on environment
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    
    // Set up logger listener
    Logger.root.onRecord.listen((record) {
      final message = '${record.level.name}: ${record.message}';
      
      if (kDebugMode) {
        // Print to console in debug mode
        developer.log(
          message,
          name: record.loggerName,
          time: record.time,
          level: record.level.value,
          error: record.error,
          stackTrace: record.stackTrace,
        );
      }
      
      // Log to Crashlytics in production
      if (record.level >= Level.WARNING && !kDebugMode) {
        FirebaseCrashlytics.instance.log(message);
        
        if (record.error != null) {
          FirebaseCrashlytics.instance.recordError(
            record.error!,
            record.stackTrace,
            reason: record.message,
          );
        }
      }
    });
    
    _isInitialized = true;
    _logger.info('Logging service initialized');
  }
  
  // Debug level logging
  void debug(String message) {
    _logger.fine(message);
  }
  
  // Info level logging
  void info(String message) {
    _logger.info(message);
  }
  
  // Warning level logging
  void warn(String message) {
    _logger.warning(message);
  }
  
  // Error level logging
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
  
  // Fatal level logging
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.shout(message, error, stackTrace);
    
    // Report to Crashlytics
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: true,
      );
    }
  }
}