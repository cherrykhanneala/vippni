import 'package:flutter/material.dart';

enum LoadingSize { small, medium, large }

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final LoadingSize size;
  final Color? color;
  final bool withScaffold;
  
  const LoadingIndicator({
    this.message,
    this.size = LoadingSize.medium,
    this.color,
    this.withScaffold = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = _buildLoadingWidget(context);
    
    if (withScaffold) {
      return Scaffold(
        body: Center(
          child: loadingWidget,
        ),
      );
    }
    
    return loadingWidget;
  }
  
  Widget _buildLoadingWidget(BuildContext context) {
    final double indicatorSize = _getIndicatorSize();
    final double strokeWidth = size == LoadingSize.small ? 2 : 3;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: indicatorSize,
          width: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: color != null 
                ? AlwaysStoppedAnimation<Color>(color!)
                : null,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getTextSize(),
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ],
    );
  }
  
  double _getIndicatorSize() {
    switch (size) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 32;
      case LoadingSize.large:
        return 48;
    }
  }
  
  double _getTextSize() {
    switch (size) {
      case LoadingSize.small:
        return 12;
      case LoadingSize.medium:
        return 14;
      case LoadingSize.large:
        return 16;
    }
  }
}

// Overlay loading indicator (for use during operations)
class OverlayLoadingIndicator extends StatelessWidget {
  final String? message;
  
  const OverlayLoadingIndicator({this.message, Key? key}) : super(key: key);
  
  // Show the loading overlay - call this from any screen
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OverlayLoadingIndicator(message: message),
    );
  }
  
  // Hide the loading overlay
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing by back button
      child: Dialog(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        insetPadding: const EdgeInsets.all(0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: LoadingIndicator(
              message: message ?? 'Loading...',
              size: LoadingSize.medium,
            ),
          ),
        ),
      ),
    );
  }
}