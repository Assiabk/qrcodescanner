import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddMemberPage extends StatefulWidget {
  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _qrCodeData;

  Future<void> _addMember() async {
    try {
      final String newQRCode = Uuid().v4();
      await _firestore.collection('members').add({
        'contact': _contactController.text,
        'fullname': _fullnameController.text,
        'id': Uuid().v1(),
        'qrCodeData': newQRCode,
      });

      setState(() {
        _qrCodeData = newQRCode;
      });

      _contactController.clear();
      _fullnameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Membre ajouté avec succès !',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de l’ajout du membre.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Générer un code QR',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Contact', _contactController, Icons.phone),
            const SizedBox(height: 16),
            _buildTextField('Nom complet', _fullnameController, Icons.person),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 18, 18, 18),
                  shadowColor: const Color.fromARGB(255, 25, 25, 26),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Ajouter un membre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_qrCodeData != null) _buildQRCode(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
        prefixIcon: Icon(icon, size: 22, color: Colors.black),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color.fromARGB(255, 104, 93, 105), width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget _buildQRCode() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Code QR généré :',
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: QrImageView(
              data: _qrCodeData!,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Ce QR code appartient au nouveau membre.\nVeuillez le sauvegarder ou l'imprimer.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
