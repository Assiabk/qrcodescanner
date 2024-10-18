import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'MainScan.dart'; 

class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  @override
  Widget build(BuildContext context) {

    const Color primaryColor = Color(0xFFFFC107); 
    const Color backgroundColor = Color(0xFF212121); 

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
 
          Positioned.fill(
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                color: primaryColor,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Center content at the top
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // QR Code Icon
                        Icon(
                          Icons.qr_code_2,
                          size: 150,
                          color: backgroundColor,
                        ),
                        const SizedBox(height: 20),

                        // Primary Subtitle Text
                        Text(
                          'Get Started',
                          style: GoogleFonts.poppins(
                            color: backgroundColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                 
                        const SizedBox(height: 15),

  
                        Text(
                          'Scan any QR code to unlock offers, \naccess content, and explore more.',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Button at the bottom center
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
                        backgroundColor: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Let\'s Start',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
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


class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);

    var firstControlPoint = Offset(size.width / 4, size.height * 0.6);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.7);
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(3 * size.width / 4, size.height * 0.8);
    var secondEndPoint = Offset(size.width, size.height * 0.7);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
