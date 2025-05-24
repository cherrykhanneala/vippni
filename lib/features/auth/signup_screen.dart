import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/auth_service.dart';
import '../../screens/profile_menu/terms_and_conditions.dart';
import '../../screens/profile_menu/privacy_policy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();

  final AuthService _auth = AuthService();
  int _currentStep = 0;

  // Step 1 - Personal Details Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Step 2 - Shop Details Controllers
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();

  // Step 3 - Business Details Controllers
  final TextEditingController _postageTypeController = TextEditingController();
  final List<String> _productTypes = [];
  final TextEditingController _productTypeController = TextEditingController();

  // State variables
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _homeAddressController.dispose();
    _postageTypeController.dispose();
    _productTypeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
      _errorMessage = '';
    });
  }

  void _addProductType() {
    if (_productTypeController.text.trim().isNotEmpty) {
      setState(() {
        _productTypes.add(_productTypeController.text.trim());
        _productTypeController.clear();
      });
    }
  }

  void _removeProductType(int index) {
    setState(() {
      _productTypes.removeAt(index);
    });
  }

  Future<void> _submitStep1() async {
    if (!(_formKey1.currentState?.validate() ?? false)) {
      return;
    }

    if (!_acceptTerms || !_acceptPrivacy) {
      setState(() {
        _errorMessage =
            'Please accept Terms and Conditions and Privacy Policy to continue.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final AuthResult result = await _auth.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
        '', // Shop name - empty for now
        '', // Shop address - empty for now
        '', // Home address - empty for now
        '', // Postage type - empty for now
        [], // Product types - empty for now
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // Save login session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        _nextStep(); // Move to step 2
      } else {
        setState(() {
          _errorMessage = result.errorMessage ??
              'Sign up failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _submitStep2() async {
    if (_formKey2.currentState?.validate() ?? true) {
      // Update user profile with shop details if provided
      if (_shopNameController.text.trim().isNotEmpty ||
          _shopAddressController.text.trim().isNotEmpty ||
          _homeAddressController.text.trim().isNotEmpty) {
        try {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('vendors')
                .doc(user.uid)
                .update({
              'shopName': _shopNameController.text.trim(),
              'shopAddress': _shopAddressController.text.trim(),
              'homeAddress': _homeAddressController.text.trim(),
            });
          }
        } catch (e) {
          print('Error updating shop details: $e');
        }
      }
    }
    _nextStep();
  }

  Future<void> _submitStep3() async {
    // Update user profile with business details if provided
    if (_postageTypeController.text.trim().isNotEmpty || _productTypes.isNotEmpty) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('vendors')
              .doc(user.uid)
              .update({
            'postageType': _postageTypeController.text.trim(),
            'productTypes': _productTypes,
          });
        }
      } catch (e) {
        print('Error updating business details: $e');
      }
    }

    _navigateToHome();
  }

  void _skipToHome() {
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  Future<void> _showTermsAndConditions() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => const TermsAndConditions(),
    );

    setState(() {
      _acceptTerms = result ?? false;
    });
  }

  Future<void> _showPrivacyPolicy() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => const PrivacyPolicy(),
    );

    setState(() {
      _acceptPrivacy = result ?? false;
    });
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
        child: Column(
          children: [
            // Header with progress
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // App title and tagline
                  Row(
                    children: [
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
                      const Spacer(),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: _skipToHome,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xFF31135F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress indicator
                  Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? const Color(0xFF31135F)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Step title
                  Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF31135F),
                    ),
                  ),

                  Text(
                    _getStepSubtitle(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Create Account';
      case 1:
        return 'Shop Details';
      case 2:
        return 'Business Info';
      default:
        return 'Sign Up';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Let\'s get you started with your account';
      case 1:
        return 'Tell us about your shop (optional)';
      case 2:
        return 'Complete your business setup (optional)';
      default:
        return '';
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Full Name field
            _buildTextField(
              controller: _fullNameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email field
            _buildTextField(
              controller: _emailController,
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password field
            _buildTextField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Confirm Password field
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Terms and Privacy checkboxes
            _buildCheckboxTile(
              title: 'I accept the Terms and Conditions',
              value: _acceptTerms,
              onTap: _showTermsAndConditions,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                  _clearError();
                });
              },
            ),

            const SizedBox(height: 8),

            _buildCheckboxTile(
              title: 'I accept the Privacy Policy',
              value: _acceptPrivacy,
              onTap: _showPrivacyPolicy,
              onChanged: (value) {
                setState(() {
                  _acceptPrivacy = value ?? false;
                  _clearError();
                });
              },
            ),

            const SizedBox(height: 24),

            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            // Sign Up button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitStep1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31135F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Shop Name field
            _buildTextField(
              controller: _shopNameController,
              hintText: 'Shop Name',
              prefixIcon: Icons.store_outlined,
            ),

            const SizedBox(height: 16),

            // Shop Address field
            _buildTextField(
              controller: _shopAddressController,
              hintText: 'Shop Address',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Home Address field
            _buildTextField(
              controller: _homeAddressController,
              hintText: 'Home Address',
              prefixIcon: Icons.home_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 48),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31135F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Skip button
            TextButton(
              onPressed: _skipToHome,
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: Color(0xFF31135F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey3,
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Postage Type field
            _buildTextField(
              controller: _postageTypeController,
              hintText: 'Postage Type (e.g., Standard, Express)',
              prefixIcon: Icons.local_shipping_outlined,
            ),

            const SizedBox(height: 24),

            // Product Types section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Product Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Add Product Type field
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _productTypeController,
                    hintText: 'Add product type',
                    prefixIcon: Icons.category_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF31135F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _addProductType,
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Product Types list
            if (_productTypes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Added Product Types:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _productTypes.asMap().entries.map((entry) {
                        int index = entry.key;
                        String type = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ABDFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF4ABDFF).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                type,
                                style: const TextStyle(
                                  color: Color(0xFF31135F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeProductType(index),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF31135F),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 48),

            // Finish Setup button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitStep3,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ABDFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Finish Setup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Skip button
            TextButton(
              onPressed: _skipToHome,
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: Color(0xFF31135F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        onChanged: (_) => _clearError(),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required VoidCallback onTap,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF31135F),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF31135F),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
