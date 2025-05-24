import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Upload Products',
      description:
          'Add new items to your store in seconds: snap or choose photos, write descriptions, set prices and inventory—then publish!',
      illustration: (context) => const UploadProductsIllustration(),
    ),
    OnboardingItem(
      title: 'Manage Orders',
      description:
          'Receive instant order alerts, review customer details, and update statuses (Pending → Shipped → Delivered) right from your phone.',
      illustration: (context) => const ManageOrdersIllustration(),
    ),
    OnboardingItem(
      title: 'Track Your Earnings',
      description:
          'View sales reports, revenue summaries and inventory trends at a glance so you can optimize and grow your business.',
      illustration: (context) => const TrackEarningsIllustration(),
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _navigateToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _navigateToAuthWrapper() {
    Navigator.pushReplacementNamed(context, '/auth_wrapper');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentPage + 1}/${_pages.length}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToAuthWrapper,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(item: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots indicator
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? const Color(0xFF31135F)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _navigateToPreviousPage,
                          child: const Text(
                            'Prev',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      _currentPage < _pages.length - 1
                          ? ElevatedButton(
                              onPressed: _navigateToNextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF31135F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Next'),
                            )
                          : ElevatedButton(
                              onPressed: _navigateToAuthWrapper,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4ABDFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Get Started'),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final Widget Function(BuildContext) illustration;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          SizedBox(
            height: 300,
            child: item.illustration(context),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF31135F),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class UploadProductsIllustration extends StatelessWidget {
  const UploadProductsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: UploadProductsPainter(),
      size: const Size(double.infinity, 300),
    );
  }
}

class UploadProductsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Set up the colors
    final primaryColor = const Color(0xFF31135F);
    final accentColor = const Color(0xFF4ABDFF);
    final goldColor = const Color(0xFFFFB23D);
    
    // Paint for shop/counter
    final shopPaint = Paint()..color = primaryColor.withOpacity(0.8);
    
    // Paint for clothing items
    final clothingPaint1 = Paint()..color = goldColor;
    final clothingPaint2 = Paint()..color = accentColor;
    
    // Draw shop counter
    final counterRect = Rect.fromLTWH(
      size.width * 0.1, 
      size.height * 0.6, 
      size.width * 0.8, 
      size.height * 0.3
    );
    canvas.drawRect(counterRect, shopPaint);
    
    // Draw mannequin
    final mannequinPaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3), 
      20, 
      mannequinPaint
    );
    
    // Draw mannequin body
    final bodyPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.35)
      ..lineTo(size.width * 0.25, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..close();
    canvas.drawPath(bodyPath, mannequinPaint);
    
    // Draw clothing items
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.2, 40, 60), 
      clothingPaint1
    );
    
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.65, size.height * 0.3, 50, 40), 
      clothingPaint2
    );
    
    // Draw phone/camera for taking product photos
    final cameraPaint = Paint()..color = Colors.black87;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.7, size.height * 0.1, 50, 80),
        const Radius.circular(8)
      ), 
      cameraPaint
    );
    
    // Draw camera lens
    final lensPaint = Paint()..color = accentColor;
    canvas.drawCircle(
      Offset(size.width * 0.7 + 25, size.height * 0.1 + 25), 
      10, 
      lensPaint
    );
    
    // Draw upload icon
    final uploadPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final uploadPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.5, size.height * 0.05)
      ..lineTo(size.width * 0.6, size.height * 0.05);
    
    canvas.drawPath(uploadPath, uploadPaint);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.05), 
      8, 
      Paint()..color = goldColor
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ManageOrdersIllustration extends StatelessWidget {
  const ManageOrdersIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ManageOrdersPainter(),
      size: const Size(double.infinity, 300),
    );
  }
}

class ManageOrdersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = const Color(0xFF31135F);
    final accentColor = const Color(0xFF4ABDFF);
    final notificationColor = const Color(0xFFFF5252);
    
    // Draw smartphone
    final phonePaint = Paint()..color = Colors.black87;
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.4,
        height: size.height * 0.7
      ),
      const Radius.circular(20)
    );
    canvas.drawRRect(phoneRect, phonePaint);
    
    // Draw phone screen
    final screenPaint = Paint()..color = Colors.white;
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.35,
        height: size.height * 0.65
      ),
      const Radius.circular(15)
    );
    canvas.drawRRect(screenRect, screenPaint);
    
    // Draw notification icon
    final notificationPaint = Paint()..color = notificationColor;
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.2), 
      15, 
      notificationPaint
    );
    
    // Draw order items as list elements
    for (int i = 0; i < 3; i++) {
      final listItemPaint = Paint()..color = i == 0 ? accentColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1);
      final listItemRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.35, 
          size.height * 0.25 + (i * 50), 
          size.width * 0.25, 
          40
        ),
        const Radius.circular(5)
      );
      canvas.drawRRect(listItemRect, listItemPaint);
      
      // Draw status icons
      final statusPaint = Paint()..color = i == 0 ? primaryColor : Colors.grey;
      canvas.drawCircle(
        Offset(size.width * 0.55, size.height * 0.25 + (i * 50) + 20), 
        5, 
        statusPaint
      );
    }
    
    // Draw person figure on left side
    final personPaint = Paint()..color = primaryColor;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3), 
      20, 
      personPaint
    );
    
    final bodyPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.35)
      ..lineTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..close();
    canvas.drawPath(bodyPath, personPaint);
    
    // Draw package/box
    final packagePaint = Paint()..color = const Color(0xFFFFB23D);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.55, 40, 40),
      packagePaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrackEarningsIllustration extends StatelessWidget {
  const TrackEarningsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrackEarningsPainter(),
      size: const Size(double.infinity, 300),
    );
  }
}

class TrackEarningsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = const Color(0xFF31135F);
    final accentColor = const Color(0xFF4ABDFF);
    final goldColor = const Color(0xFFFFB23D);
    
    // Draw graph background
    final graphBgPaint = Paint()..color = Colors.grey.withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.6, size.height * 0.4),
      graphBgPaint
    );
    
    // Draw growth chart line
    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.65, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height * 0.35);
    
    canvas.drawPath(path, linePaint);
    
    // Draw data points
    final pointPaint = Paint()..color = primaryColor;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.6), 5, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.5), 5, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 5, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), 5, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.35), 5, pointPaint);
    
    // Draw coins/money icons
    for (int i = 0; i < 3; i++) {
      final coinPaint = Paint()..color = goldColor;
      canvas.drawCircle(
        Offset(size.width * (0.3 + (i * 0.2)), size.height * 0.15),
        15,
        coinPaint
      );
      
      // Draw dollar sign
      final dollarPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final dollarPath = Path()
        ..moveTo(size.width * (0.3 + (i * 0.2)), size.height * 0.12)
        ..lineTo(size.width * (0.3 + (i * 0.2)), size.height * 0.18);
      
      canvas.drawPath(dollarPath, dollarPaint);
    }
    
    // Draw report icon
    final reportPaint = Paint()..color = primaryColor.withOpacity(0.8);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.4, 40, 50),
      reportPaint
    );
    
    // Draw report lines
    final linePaint2 = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.12, size.height * (0.45 + (i * 0.05))),
        Offset(size.width * 0.18, size.height * (0.45 + (i * 0.05))),
        linePaint2
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}