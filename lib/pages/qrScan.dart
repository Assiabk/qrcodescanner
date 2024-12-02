import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'MainScan.dart';
import 'dart:math';

class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for wave effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0, end: 20).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Updated color scheme
    const Color primaryColor = Color(0xFF0072CE); // New blue color
    const Color backgroundColor = Color(0xFF121212); // Darker background for contrast

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated Wave Background
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: ClipPath(
                  clipper: WaveClipper(_waveAnimation.value),
                  child: Container(
                    color: primaryColor,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                // Center content at the top with Fade & Slide animation
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Fade & Slide-in Animation for QR Code Icon
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 1500),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, -0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOut,
                            )),
                            child: Icon(
                              Icons.qr_code_2,
                              size: 150,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Elegant Title Text with Animation
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 1500),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, -0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOut,
                            )),
                            child: Text(
                              'NocEvent',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),

                // Button at the bottom with Ripple Effect
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Mainscan()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shadowColor: primaryColor.withOpacity(0.5),
                        elevation: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Commencer',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Wave Clipper with adjustable wave height for animation
class WaveClipper extends CustomClipper<Path> {
  final double waveHeight;

  WaveClipper(this.waveHeight);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);

    var firstControlPoint = Offset(size.width / 4, size.height * 0.6 + waveHeight);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.7);

    var secondControlPoint = Offset(3 * size.width / 4, size.height * 0.8 - waveHeight);
    var secondEndPoint = Offset(size.width, size.height * 0.7);

    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
