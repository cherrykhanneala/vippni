// auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

class AuthResult {
  final User? user;
  final String? errorMessage;
  final bool isSuccess;

  AuthResult({this.user, this.errorMessage, this.isSuccess = false});

  factory AuthResult.success(User user) {
    return AuthResult(user: user, isSuccess: true);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(errorMessage: errorMessage, isSuccess: false);
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Expose the auth state changes stream
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
    String shopName,
    String shopAddress,
    String homeAddress,
    String postageType,
    List<String> productTypes,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        String vendorId = user.uid;

        // Create vendor document with only required fields initially
        Map<String, dynamic> vendorData = {
          'fullName': fullName,
          'email': email,
          'role': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Add optional fields only if they're not empty
        if (shopName.isNotEmpty) vendorData['shopName'] = shopName;
        if (shopAddress.isNotEmpty) vendorData['shopAddress'] = shopAddress;
        if (homeAddress.isNotEmpty) vendorData['homeAddress'] = homeAddress;
        if (postageType.isNotEmpty) vendorData['postageType'] = postageType;
        if (productTypes.isNotEmpty) vendorData['productTypes'] = productTypes;

        await _firestore.collection('vendors').doc(vendorId).set(vendorData);

        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Failed to create user account');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException in signUpWithEmailPassword: ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      print('Error in signUpWithEmailPassword: $e');
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  // Enhanced Sign in with email and password with comprehensive error handling
  Future<AuthResult> signInWithEmailPassword(String email, String password) async {
    try {
      // Pre-validation
      if (email.trim().isEmpty || password.trim().isEmpty) {
        return AuthResult.failure('Email and password cannot be empty.');
      }

      // Wrap Firebase call in additional error handling
      UserCredential? result;
      
      try {
        result = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Authentication request timed out', const Duration(seconds: 30));
          },
        );
      } on FirebaseAuthException catch (e) {
        // Handle Firebase auth exceptions immediately
        print('FirebaseAuthException caught: ${e.code} - ${e.message}');
        return AuthResult.failure(_getAuthErrorMessage(e));
      } on PlatformException catch (e) {
        // Handle platform exceptions
        print('PlatformException caught: ${e.code} - ${e.message}');
        return AuthResult.failure(_getPlatformErrorMessage(e));
      } on TimeoutException catch (e) {
        print('TimeoutException caught: ${e.message}');
        return AuthResult.failure('Authentication request timed out. Please try again.');
      } on SocketException catch (e) {
        print('SocketException caught: ${e.message}');
        return AuthResult.failure('Network error. Please check your internet connection.');
      }
      
      // Check if authentication was successful
      if (result?.user != null) {
        print('Authentication successful for user: ${result!.user!.uid}');
        return AuthResult.success(result.user!);
      } else {
        print('Authentication failed - no user returned');
        return AuthResult.failure('Authentication failed - please try again.');
      }

    } on FirebaseAuthException catch (e) {
      // Secondary catch for any Firebase exceptions that slip through
      print('Secondary FirebaseAuthException catch: ${e.code} - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e));
    } on PlatformException catch (e) {
      // Secondary catch for platform exceptions
      print('Secondary PlatformException catch: ${e.code} - ${e.message}');
      return AuthResult.failure(_getPlatformErrorMessage(e));
    } catch (e) {
      // Catch-all for any other exceptions
      print('Unexpected error in signInWithEmailPassword: $e');
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  // Handle platform-specific errors
  String _getPlatformErrorMessage(PlatformException e) {
    print('Processing platform error: ${e.code} - ${e.message}');
    
    switch (e.code.toLowerCase()) {
      case 'channel-error':
        return 'Communication error. Please restart the app and try again.';
      case 'null-error':
        return 'Authentication failed. Please check your credentials and try again.';
      case 'network_error':
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      default:
        // For authentication-related platform errors, provide a generic auth message
        if (e.message?.toLowerCase().contains('auth') == true ||
            e.message?.toLowerCase().contains('credential') == true ||
            e.message?.toLowerCase().contains('password') == true ||
            e.message?.toLowerCase().contains('email') == true) {
          return 'Invalid login credentials. Please check your email and password.';
        }
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    print('Processing Firebase auth error: ${e.code} - ${e.message}');
    
    switch (e.code.toLowerCase()) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid login credentials. Please check your email and password.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      case 'invalid-api-key':
        return 'Invalid API key configuration.';
      case 'invalid-user-token':
        return 'Your session has expired. Please sign in again.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to continue.';
      default:
        // Return the original message for unknown errors, but ensure it's user-friendly
        String originalMessage = e.message ?? 'Authentication failed';
        if (originalMessage.toLowerCase().contains('credential') ||
            originalMessage.toLowerCase().contains('password') ||
            originalMessage.toLowerCase().contains('email')) {
          return 'Invalid login credentials. Please check your email and password.';
        }
        return 'Authentication failed. Please try again.';
    }
  }

  // Get vendor role
  Future<String?> getVendorRole(String vendorId) async {
    try {
      DocumentSnapshot vendorDoc =
          await _firestore.collection('vendors').doc(vendorId).get();
      if (vendorDoc.exists) {
        return vendorDoc['role'];
      } else {
        print('Vendor document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching vendor role: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Update product
  Future<void> updateProduct(
    String productId,
    String productName,
    String productDescription,
    double productPrice,
    int productQuantity,
    String productType,
    String productAvailability,
    double weight,
    String weightUnit,
    double length,
    double width,
    double height,
    String dimensionUnit,
    String material,
    String envelopeSize,
    List<String> colors,
    List<String> tags,
    List<String> imageUrls,
  ) async {
    try {
      final productData = {
        'name': productName,
        'description': productDescription,
        'price': productPrice,
        'quantity': productQuantity,
        'type': productType,
        'availability': productAvailability,
        'weight': weight,
        'weightUnit': weightUnit,
        'length': length,
        'width': width,
        'height': height,
        'dimensionUnit': dimensionUnit,
        'material': material,
        'envelopeSize': envelopeSize,
        'colors': colors,
        'tags': tags,
        'images': imageUrls,
        'userId': _auth.currentUser!.uid,
      };

      await _firestore
          .collection('products')
          .doc(productId)
          .update(productData);
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  // Add product
  Future<void> addProduct(
    String productId,
    String productName,
    String productDescription,
    double productPrice,
    int productQuantity,
    String productType,
    String productAvailability,
    double weight,
    String weightUnit,
    double length,
    double width,
    double height,
    String dimensionUnit,
    String material,
    String envelopeSize,
    List<String> colors,
    List<String> tags,
    List<String> imageUrls,
  ) async {
    try {
      final productData = {
        'name': productName,
        'description': productDescription,
        'price': productPrice,
        'quantity': productQuantity,
        'type': productType,
        'availability': productAvailability,
        'weight': weight,
        'weightUnit': weightUnit,
        'length': length,
        'width': width,
        'height': height,
        'dimensionUnit': dimensionUnit,
        'material': material,
        'envelopeSize': envelopeSize,
        'colors': colors,
        'tags': tags,
        'images': imageUrls,
        'userId': _auth.currentUser!.uid,
      };

      await _firestore
          .collection('products')
          .doc(productId)
          .set(productData);
    } catch (e) {
      print('Error adding product: $e');
    }
  }
}
