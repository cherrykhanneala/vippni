import 'package:flutter/material.dart';
import 'dart:async';

class ErrorHandler {
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static T? handleOperation<T>(
    BuildContext context,
    T? Function() operation,
    {String errorMessage = 'An error occurred'}) {
    try {
      return operation();
    } catch (e) {
      showErrorSnackbar(context, '$errorMessage: ${e.toString()}');
      return null;
    }
  }

  static Future<T?> handleFuture<T>(
    BuildContext context,
    Future<T> future, {
    String errorMessage = 'An error occurred',
    Function()? onError,
  }) async {
    try {
      return await future;
    } catch (e) {
      if (onError != null) {
        onError();
      }
      showErrorSnackbar(context, '$errorMessage: ${e.toString()}');
      return null;
    }
  }
}