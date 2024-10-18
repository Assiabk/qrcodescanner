import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/services.dart'; // Import to use Clipboard
import 'package:permission_handler/permission_handler.dart';

class Mainscan extends StatefulWidget {
  const Mainscan({Key? key}) : super(key: key);

  @override
  _MainscanState createState() => _MainscanState();
}

class _MainscanState extends State<Mainscan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrContent = 'Scan a QR code';
  bool isLink = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required to scan QR codes.')),
      );
    }
  }

  void _onQRViewCreated(QRViewController qrController) {
    setState(() {
      controller = qrController;
    });

    controller!.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        setState(() {
          qrContent = scanData.code!;
          isLink = Uri.tryParse(qrContent)?.hasScheme ?? false;
        });
      }
    });
  }

  Future<void> _copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content copied to clipboard')),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.orange,
                  borderRadius: 15, // Rounded corners
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[850], // Darker container color
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    isLink ? 'Link Detected:' : 'Scanned Content:',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    qrContent,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: isLink ? Colors.lightBlueAccent : Colors.white,
                      decoration: TextDecoration.none, // Removed underline
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(qrContent),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy to Clipboard'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded button
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the button to copy the content.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
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
