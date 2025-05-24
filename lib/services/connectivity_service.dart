import 'dart:async';
import 'package:flutter/material.dart';
import 'logging_service.dart';

// Add these to your pubspec.yaml first:
// dependencies:
//   connectivity_plus: ^4.0.2

// Then uncomment the import:
// import 'package:connectivity_plus/connectivity_plus.dart';

// For now, let's create a placeholder to fix the errors
enum ConnectivityResult { wifi, mobile, none }

class Connectivity {
  Future<ConnectivityResult> checkConnectivity() async {
    // This is a placeholder. Install connectivity_plus package for real implementation
    return ConnectivityResult.wifi;
  }
  
  Stream<ConnectivityResult> get onConnectivityChanged => 
      Stream.periodic(Duration(seconds: 5))
          .asyncMap((_) => checkConnectivity());
}

enum NetworkStatus { online, offline }

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final LoggingService _logger = LoggingService();
  
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  NetworkStatus _status = NetworkStatus.online;
  bool _isInitialized = false;

  NetworkStatus get status => _status;
  bool get isOnline => _status == NetworkStatus.online;
  bool get isOffline => _status == NetworkStatus.offline;

  ConnectivityService() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    if (_isInitialized) return;
    
    try {
      ConnectivityResult result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
      _isInitialized = true;
    } catch (e) {
      _logger.error('Error initializing connectivity service: $e');
      _status = NetworkStatus.offline;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _status = NetworkStatus.offline;
      _logger.info('Network status: Offline');
    } else {
      _status = NetworkStatus.online;
      _logger.info('Network status: Online (${result.name})');
    }
    
    notifyListeners();
  }

  Future<bool> checkConnectivity() async {
    try {
      ConnectivityResult result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return result != ConnectivityResult.none;
    } catch (e) {
      _logger.error('Error checking connectivity: $e');
      return false;
    }
  }
  
  // Use this to show a banner when offline
  Widget buildOfflineBanner() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: isOffline
          ? Container(
              color: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'You are offline. Some features may be limited.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}