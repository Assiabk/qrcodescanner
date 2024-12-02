import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SuiviUtilisateur.dart'; 

class DetailleEvenements extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const DetailleEvenements({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'événement', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          _buildAppBarButton(
            context,
            label: "Tableau de bord",
            onPressed: () {},
          ),
          _buildAppBarButton(
            context,
            label: "Suivi utilisateur",
            onPressed: () {
          
          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SuiviUtilisateur(
      eventName: eventData['event_name'], eventData: {}, 

    ),
  ),
);

            }
          ),
          _buildAppBarButton(
            context,
            label: "Suivi présence",
            onPressed: () {},
          ),
          _buildAppBarButton(
            context,
            label: "Vote",
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom de l\'événement: ${eventData['event_name']}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12), 
            Text(
              'Date de début: ${eventData['start_date']}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Statut: ${eventData['status']}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF0F0F0), 
    );
  }



  Widget _buildAppBarButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
