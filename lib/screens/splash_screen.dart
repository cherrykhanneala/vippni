import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate after splash screen delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF31135F), // Primary splash color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App splash image
            Image.asset(
              'assets/splash.png',
              width: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 32.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText('VIPPNI'),
                  FadeAnimatedText(
                    'YOUR WORLDWIDE SHOP PLATFORM',
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            const SizedBox(height: 40),
            // Add loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
