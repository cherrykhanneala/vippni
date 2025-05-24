import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;
  bool _emailSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      
      if (!mounted) return;
      
      setState(() {
        _emailSent = true;
        _isSuccess = true;
        _message = 'Password reset email sent successfully! Check your inbox and follow the instructions to reset your password.';
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getAuthErrorMessage(e);
      if (mounted) {
        setState(() {
          _isSuccess = false;
          _message = errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSuccess = false;
          _message = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Failed to send reset email. Please try again.';
    }
  }

  void _clearMessage() {
    if (_message.isNotEmpty) {
      setState(() {
        _message = '';
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
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
                
                // Back button and app title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF31135F),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VIPPNI',
                          style: TextStyle(
                            fontSize: 18,
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
                  ],
                ),
                
                const SizedBox(height: 36),
                
                // Header section
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF31135F),
                  ),
                ),
                
                Text(
                  _emailSent 
                      ? 'Check your email for reset instructions'
                      : 'Enter your email to receive reset instructions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Illustration
                Center(
                  child: SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: _emailSent 
                          ? EmailSentIllustrationPainter()
                          : ForgotPasswordIllustrationPainter(),
                      size: const Size(double.infinity, 200),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Form or success content
                if (!_emailSent) ...[
                  // Email form
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
                            onChanged: (_) => _clearMessage(),
                            decoration: InputDecoration(
                              hintText: 'Your Email',
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Send Reset Email button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendPasswordResetEmail,
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
                                    'Send Reset Email',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Success content
                  Column(
                    children: [
                      // Resend email button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _emailSent = false;
                              _message = '';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ABDFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Send Another Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Back to Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _navigateToLogin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF31135F),
                            side: const BorderSide(color: Color(0xFF31135F)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Message display
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _message.isNotEmpty ? null : 0,
                  child: _message.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isSuccess ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isSuccess 
                                  ? Colors.green.shade200 
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                                color: _isSuccess 
                                    ? Colors.green.shade700 
                                    : Colors.red.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _message,
                                  style: TextStyle(
                                    color: _isSuccess 
                                        ? Colors.green.shade700 
                                        : Colors.red.shade700,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (!_isSuccess)
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  onPressed: _clearMessage,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                
                if (!_emailSent) ...[
                  // Back to login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF4ABDFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = const Color(0xFF31135F);
    final accentColor = const Color(0xFF4ABDFF);
    final tertiaryColor = const Color(0xFFFFB23D);
    
    // Draw person figure
    // Person head
    final headPaint = Paint()..color = primaryColor;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.08,
      headPaint
    );

    // Person body
    final bodyPaint = Paint()..color = tertiaryColor;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.33,
        size.width * 0.16,
        size.height * 0.3
      ),
      const Radius.circular(12)
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Person legs
    final legPaint = Paint()..color = primaryColor;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.63,
        size.width * 0.04,
        size.height * 0.3
      ),
      legPaint
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.51,
        size.height * 0.63,
        size.width * 0.04,
        size.height * 0.3
      ),
      legPaint
    );

    // Person arms - one hand scratching head (confused gesture)
    final armPaint = Paint()
      ..color = tertiaryColor
      ..strokeWidth = size.width * 0.03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Right arm to head
    final rightArmPath = Path()
      ..moveTo(size.width * 0.58, size.height * 0.37)
      ..lineTo(size.width * 0.55, size.height * 0.22);
    canvas.drawPath(rightArmPath, armPaint);

    // Left arm hanging down
    final leftArmPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.37)
      ..lineTo(size.width * 0.38, size.height * 0.5);
    canvas.drawPath(leftArmPath, armPaint);

    // Draw question marks around the person
    final questionPaint = Paint()..color = accentColor.withOpacity(0.7);
    final questionTextPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          fontSize: size.width * 0.12,
          fontWeight: FontWeight.bold,
          color: accentColor.withOpacity(0.7),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    questionTextPainter.layout();
    
    // Multiple question marks at different positions
    questionTextPainter.paint(canvas, Offset(size.width * 0.2, size.height * 0.15));
    questionTextPainter.paint(canvas, Offset(size.width * 0.75, size.height * 0.25));
    questionTextPainter.paint(canvas, Offset(size.width * 0.15, size.height * 0.45));
    questionTextPainter.paint(canvas, Offset(size.width * 0.8, size.height * 0.55));

    // Draw lock icon (representing locked account/forgotten password)
    final lockPaint = Paint()..color = Colors.red.shade400;
    
    // Lock body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.35, size.height * 0.7),
          width: size.width * 0.08,
          height: size.width * 0.06,
        ),
        const Radius.circular(4),
      ),
      lockPaint
    );

    // Lock shackle
    final lockShacklePaint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.68),
        width: size.width * 0.05,
        height: size.width * 0.05,
      ),
      -3.14, // Start angle (top)
      3.14,  // Sweep angle (half circle)
      false,
      lockShacklePaint,
    );

    // Draw email icon (suggesting email reset)
    final emailPaint = Paint()..color = accentColor;
    
    // Email envelope
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.65, size.height * 0.7),
          width: size.width * 0.12,
          height: size.width * 0.08,
        ),
        const Radius.circular(4),
      ),
      emailPaint
    );

    // Email flap
    final emailFlapPaint = Paint()
      ..color = accentColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final emailFlapPath = Path()
      ..moveTo(size.width * 0.59, size.height * 0.66)
      ..lineTo(size.width * 0.65, size.height * 0.7)
      ..lineTo(size.width * 0.71, size.height * 0.66);
    
    canvas.drawPath(emailFlapPath, emailFlapPaint);

    // Draw floating dots for visual interest
    final dotPaint = Paint()..color = tertiaryColor.withOpacity(0.6);
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * 3.14 * 2) / 8;
      final radius = size.width * 0.3;
      final centerX = size.width * 0.5;
      final centerY = size.height * 0.5;
      
      final x = centerX + radius * 0.6 * (angle / (3.14 * 2));
      final y = centerY + radius * 0.4 * (angle / (3.14 * 2));
      
      canvas.drawCircle(
        Offset(x, y),
        size.width * 0.01,
        dotPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmailSentIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = const Color(0xFF31135F);
    final accentColor = const Color(0xFF4ABDFF);
    final successColor = const Color(0xFF4CAF50);
    final tertiaryColor = const Color(0xFFFFB23D);
    
    // Draw large email envelope
    final emailPaint = Paint()..color = Colors.white;
    final emailBorderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final emailRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.4,
        height: size.width * 0.3,
      ),
      const Radius.circular(12),
    );
    
    canvas.drawRRect(emailRect, emailPaint);
    canvas.drawRRect(emailRect, emailBorderPaint);

    // Draw email flap
    final emailFlapPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.35);
    
    canvas.drawPath(emailFlapPath, emailBorderPaint);

    // Draw checkmark inside email
    final checkPaint = Paint()
      ..color = successColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final checkPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.5)
      ..lineTo(size.width * 0.48, size.height * 0.56)
      ..lineTo(size.width * 0.58, size.height * 0.44);
    
    canvas.drawPath(checkPath, checkPaint);

    // Draw flying paper planes (representing sent emails)
    final planePaint = Paint()..color = tertiaryColor;
    
    // Paper plane 1
    final plane1Path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..lineTo(size.width * 0.25, size.height * 0.22)
      ..lineTo(size.width * 0.22, size.height * 0.28)
      ..close();
    canvas.drawPath(plane1Path, planePaint);

    // Paper plane 2
    final plane2Path = Path()
      ..moveTo(size.width * 0.75, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.27)
      ..lineTo(size.width * 0.82, size.height * 0.33)
      ..close();
    canvas.drawPath(plane2Path, planePaint);

    // Paper plane 3
    final plane3Path = Path()
      ..moveTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.9, size.height * 0.67)
      ..lineTo(size.width * 0.87, size.height * 0.73)
      ..close();
    canvas.drawPath(plane3Path, planePaint);

    // Draw dotted trails behind planes
    final trailPaint = Paint()
      ..color = tertiaryColor.withOpacity(0.5)
      ..strokeWidth = 2;
    
    // Trail 1
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.12 - i * 0.02), size.height * (0.26 + i * 0.01)),
        1.5,
        trailPaint
      );
    }

    // Trail 2
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.72 - i * 0.02), size.height * (0.31 + i * 0.01)),
        1.5,
        trailPaint
      );
    }

    // Draw success indicators around the email
    final successIndicatorPaint = Paint()..color = successColor.withOpacity(0.7);
    
    // Success circles
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.6), size.width * 0.02, successIndicatorPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), size.width * 0.02, successIndicatorPaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.45), size.width * 0.015, successIndicatorPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.6), size.width * 0.015, successIndicatorPaint);

    // Draw person figure (happy/relieved)
    final personPaint = Paint()..color = primaryColor;
    
    // Person head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      size.width * 0.06,
      personPaint
    );

    // Happy face
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Eyes
    canvas.drawCircle(Offset(size.width * 0.47, size.height * 0.13), 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * 0.53, size.height * 0.13), 2, Paint()..color = Colors.white);
    
    // Smile
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.16),
        width: size.width * 0.04,
        height: size.width * 0.04,
      ),
      0,
      3.14,
      false,
      facePaint,
    );

    // Person body (simplified)
    final bodyPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.21)
      ..lineTo(size.width * 0.45, size.height * 0.32)
      ..lineTo(size.width * 0.55, size.height * 0.32)
      ..close();
    canvas.drawPath(bodyPath, personPaint);

    // Arms raised in celebration
    final celebrationArmPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = size.width * 0.02
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.23),
      Offset(size.width * 0.4, size.height * 0.18),
      celebrationArmPaint
    );
    
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.23),
      Offset(size.width * 0.6, size.height * 0.18),
      celebrationArmPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
