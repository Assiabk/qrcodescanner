import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_app/adminpages/EventsPage.dart';
import 'package:qr_app/adminpages/createusers.dart';

import 'Eventslist.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "NocEvent",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        actions: [
          _buildAppBarButton(
            context,
            label: "Tableau de bord",
            onPressed: () {
         
            },
          ),
          _buildAppBarButton(
            context,
            label: "Événements",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const  Eventslist()),
              );
            },
          ),
          _buildAppBarButton(
            context,
            label: "Utilisateurs",
            onPressed: () {
           Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateUser()),
                      );
            },
          ),
          _buildAppBarButton(
            context,
            label: "Se déconnecter",
            onPressed: () {
              // Add functionality if needed
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Bienvenue dans votre tableau de bord, Administrateur",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 3.0,
                crossAxisSpacing: 3.0,
                children: [
                  DashboardCard(
                    title: "Événements",
                    description: "Gérez vos événements.",
                    buttonText: "Créer un événement",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateEventPage()),
                      );
                    },
                  ),
                  DashboardCard(
                    title: "Utilisateurs",
                    description: "Gérez vos utilisateurs.",
                    buttonText: "Créer un utilisateur",
                    onPressed: () {
          Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateUser()),
                      );
                    },
                  ),
                  DashboardCard(
                    title: "Statistiques",
                    description: "Voir les statistiques des événements et des utilisateurs.",
                    buttonText: "Voir les statistiques",
                    onPressed: () {
                      // Add functionality if needed
                    },
                  ),
                  DashboardCard(
                    title: "QR Codes",
                    description: "Gérez les QR Codes.",
                    buttonText: "Voir les QR Codes",
                    onPressed: () {
                      // Add functionality if needed
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminDashboard(),
  ));
}
