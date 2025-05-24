// login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        // Navigation will be handled by AuthWrapper
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'Invalid Google credential. Please try again.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with a different sign-in method.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = 'Google sign-in failed: ${e.message}';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Platform error: ${e.message ?? 'Unknown error'}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign-in failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithEmailPassword() async {
    // Clear previous errors
    setState(() {
      _errorMessage = '';
    });

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResult result = await _auth.signInWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // Success - AuthWrapper will handle navigation
        print('Login successful for user: ${result.user?.uid}');
      } else {
        // Show error message
        setState(() {
          _errorMessage = result.errorMessage ?? 'Login failed';
        });
      }
    } catch (e) {
      // Catch any unexpected errors
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
      print('Unexpected error in login: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearError() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // App title and tagline in top left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VIPPNI',
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF31135F),
                      ),
                    ),
                    Text(
                      'YOUR WORLDWIDE SHOP PLATFORM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                // Login section header
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF31135F),
                  ),
                ),
                const Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                // Login illustration
                Center(
                  child: SizedBox(
                    height: 180,
                    child: CustomPaint(
                      painter: LoginIllustrationPainter(),
                      size: const Size(double.infinity, 180),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => _clearError(),
                          decoration: InputDecoration(
                            hintText: 'Your Email',
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => _clearError(),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF31135F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginWithEmailPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF31135F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading 
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      // Error message with animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _errorMessage.isNotEmpty ? null : 0,
                        child: _errorMessage.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, 
                                         color: Colors.red.shade700, 
                                         size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: TextStyle(
                                          color: Colors.red.shade700, 
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, 
                                               color: Colors.red.shade700, 
                                               size: 20),
                                      onPressed: _clearError,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    
                      const SizedBox(height: 20),
                      // Or divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[350], thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Or',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[350], thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Social login options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google
                          _buildSocialButton(
                            onPressed: _isLoading ? () {} : _signInWithGoogle,
                            icon: Image.asset(
                              'assets/google_logo.png',
                              width: 24,
                              height: 24,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(width: 24),
                          // Facebook
                          _buildSocialButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.facebook,
                              color: Colors.white,
                              size: 28,
                            ),
                            backgroundColor: Colors.blue[600]!,
                          ),
                          const SizedBox(width: 24),
                          // Apple
                          _buildSocialButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.apple,
                              color: Colors.white,
                              size: 28,
                            ),
                            backgroundColor: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'I don\'t have account',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup_step');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF4ABDFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required Widget icon,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: backgroundColor == Colors.white
              ? Border.all(color: Colors.grey.shade300, width: 1)
              : null,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class LoginIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = const Color(0xFF31135F);
    final accentColor = const Color(0xFF4ABDFF);
    final tertiaryColor = const Color(0xFFFFB23D);
    
    // Draw door frame
    final doorFramePaint = Paint()..color = Colors.grey[300]!;
    final doorFramePath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.1)
      ..lineTo(size.width * 0.3, size.height * 0.9)
      ..lineTo(size.width * 0.7, size.height * 0.9)
      ..lineTo(size.width * 0.7, size.height * 0.1)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.1),
          radius: size.width * 0.2,
        ),
        0, 
        -3.14,
        false
      )
      ..close();
    canvas.drawPath(doorFramePath, doorFramePaint);

    // Draw door
    final doorPaint = Paint()..color = Colors.white;
    final doorPath = Path()
      ..moveTo(size.width * 0.32, size.height * 0.12)
      ..lineTo(size.width * 0.32, size.height * 0.88)
      ..lineTo(size.width * 0.68, size.height * 0.88)
      ..lineTo(size.width * 0.68, size.height * 0.12)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.12),
          radius: size.width * 0.18,
        ),
        0, 
        -3.14,
        false
      )
      ..close();
    canvas.drawPath(doorPath, doorPaint);

    // Draw door handle
    final handlePaint = Paint()..color = tertiaryColor;
    canvas.drawCircle(
      Offset(size.width * 0.36, size.height * 0.5),
      size.width * 0.02,
      handlePaint
    );

    // Draw person
    // Person head
    final headPaint = Paint()..color = primaryColor;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      size.width * 0.06,
      headPaint
    );

    // Person body
    final bodyPaint = Paint()..color = tertiaryColor;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.74,
        size.height * 0.36,
        size.width * 0.12,
        size.height * 0.25
      ),
      const Radius.circular(8)
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Person legs
    final legPaint = Paint()..color = primaryColor;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.76,
        size.height * 0.61,
        size.width * 0.03,
        size.height * 0.25
      ),
      legPaint
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.81,
        size.height * 0.61,
        size.width * 0.03,
        size.height * 0.25
      ),
      legPaint
    );

    // Person arms - one reaching toward door
    final armPaint = Paint()
      ..color = tertiaryColor
      ..strokeWidth = size.width * 0.025
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final armPath = Path()
      ..moveTo(size.width * 0.74, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.5);
    
    canvas.drawPath(armPath, armPaint);

    // Draw authentication icon/lock
    final lockPaint = Paint()..color = accentColor;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.05,
      lockPaint
    );

    final lockBodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.5),
          width: size.width * 0.04,
          height: size.width * 0.03,
        ),
        const Radius.circular(2),
      ),
      lockBodyPaint
    );

    // Draw windows on door
    final windowPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    final windowSize = size.width * 0.08;
    final windowSpacing = size.width * 0.02;
    final windowsStartY = size.height * 0.2;
    
    // Window grid 2x3
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 2; col++) {
        final windowX = size.width * 0.42 + col * (windowSize + windowSpacing);
        final windowY = windowsStartY + row * (windowSize + windowSpacing);
        
        canvas.drawRect(
          Rect.fromLTWH(windowX, windowY, windowSize, windowSize),
          windowPaint
        );
      }
    }

    // Draw plants/decorative elements
    final plantPaint = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.6);
    // Left plant
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      size.width * 0.08,
      plantPaint
    );
    // Right plant
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      size.width * 0.08,
      plantPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
