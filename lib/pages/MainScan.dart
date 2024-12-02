import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Profile.dart';
import 'voting.dart';


class Mainscan extends StatefulWidget {
  const Mainscan({Key? key}) : super(key: key);

  @override
  _MainscanState createState() => _MainscanState();
}

class _MainscanState extends State<Mainscan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrContent = 'Scannez un code QR';
  bool isLink = false;
  int _selectedIndex = 0;

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
        const SnackBar(
          content: Text(
              "L'autorisation de la caméra est requise pour scanner les codes QR."),
        ),
      );
    }
  }

  void _onQRViewCreated(QRViewController qrController) {
    setState(() {
      controller = qrController;
    });

    controller!.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        await _fetchUserData(scanData.code!);
      }
    });
  }

  Future<void> _fetchUserData(String qrCode) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('qrCodeData', isEqualTo: qrCode)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();

        final String nom = userData['nom'] ?? 'Nom non disponible';
        final String prenom = userData['prenom'] ?? 'Prénom non disponible';
        final String userId = snapshot.docs.first.id;

        await _recordAttendance(userId, nom, prenom);
        _showConfirmationAlert(nom, prenom);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun utilisateur trouvé pour ce code QR.")),
        );
      }
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la récupération des données.")),
      );
    }
  }

  Future<void> _recordAttendance(String userId, String nom, String prenom) async {
    try {
      final attendanceRef =
          FirebaseFirestore.instance.collection('attendance').doc(userId);
      await attendanceRef.set({
        'nom': nom,
        'prenom': prenom,
        'lastScan': Timestamp.now(),
        'present': true,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Erreur lors de l'enregistrement de la présence: $e");
    }
  }

  void _showConfirmationAlert(String nom, String prenom) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Présence Confirmée',
          style: TextStyle(color: Color.fromARGB(255, 248, 252, 254)),
        ),
        content: Text(
          'Bienvenue, $prenom $nom. Votre présence à cet événement est enregistrée.',
          style: const TextStyle(color: Color.fromARGB(255, 214, 210, 210)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VotingPage()));
    // } else if (index == 2) {
    //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
    // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 appBar: AppBar(
    automaticallyImplyLeading: false, 
  title: Text(
    'NocEvent',
    style: GoogleFonts.playfairDisplay(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  backgroundColor: Colors.black,
  centerTitle: true,
),

      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: const Color(0xFF0072CE),
                  borderRadius: 15,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(147, 0, 0, 0),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.qrcode,
                  color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                ),
                label: 'Scanner',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.voteYea,
                  color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                ),
                label: 'Voting',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.user,
                  color: _selectedIndex == 2 ? Colors.white : Colors.grey,
                ),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
