import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import 'admin_dashboard.dart';

class users extends StatefulWidget {
  @override
  _usersState createState() => _usersState();
}

class _usersState extends State<users> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedRole;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _ajouterUtilisateur() async {
    try {
      final String newQRCode = Uuid().v4();
      await _firestore.collection('users').add({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'contact': _contactController.text,
        'role': _selectedRole,
        'qrCodeData': newQRCode,
      });

      _nomController.clear();
      _prenomController.clear();
      _contactController.clear();
      _selectedRole = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur ajouté avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _showForm = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l’ajout de l’utilisateur.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 
  Future<void> _supprimerUtilisateur(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur supprimé avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression de l’utilisateur.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showConfirmationDialog(String userId) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.black, // Dark theme background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        title: Text(
          "Supprimer cet utilisateur", // Title text
          style: const TextStyle(
            color: Colors.white, // White text for dark theme
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer cet utilisateur?", // Confirmation message
          style: const TextStyle(color: Colors.grey), // Subtle text color
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text(
              "Annuler", // "Cancel" button
              style: TextStyle(color: Colors.grey), // Neutral "Cancel" button
            ),
          ),
          TextButton(
            onPressed: () async {
              // Call the function to delete the user
              await _supprimerUtilisateur(userId);
              Navigator.pop(context); // Close the dialog
            },
            child: const Text(
              "Supprimer", // "Delete" button
              style: TextStyle(
                color: Colors.redAccent, // Red color for "Delete"
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
  
void _showQRCodeDialog(String qrCodeData) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code de l\'utilisateur',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$qrCodeData",
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SelectableText(
                'QR Code: $qrCodeData',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Fermer',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // // Sidebar widget (You can replace this with your Sidebar widget)
          // const Sidebar(),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _showForm ? _buildForm() : _buildUserList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Utilisateurs',
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showForm = !_showForm;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: Icon(_showForm ? Icons.close : Icons.add, color: Colors.white),
            label: Text(
              _showForm ? 'Annuler' : 'Ajouter',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Nom', _nomController),
            const SizedBox(height: 16),
            _buildTextField('Prénom', _prenomController),
            const SizedBox(height: 16),
            _buildTextField('Contact', _contactController),
            const SizedBox(height: 16),
            _buildDropdown(),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _ajouterUtilisateur,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: Text(
                  'Sauvegarder',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Aucun utilisateur trouvé.',
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 18),
            ),
          );
        }

        final users = snapshot.data!.docs;

    return   ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    final user = users[index];
    return Card(
        color: Colors.black, 
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: GestureDetector(
          onTap: () => _showQRCodeDialog(user['qrCodeData']),
          child: Text(
            '${user['nom']} ${user['prenom']}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
        subtitle: Text('Role: ${user['role']} | Contact: ${user['contact']}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showConfirmationDialog(user.id), // Shows the confirmation dialog
        ),
      ),
    );
  },
);

      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
Widget _buildDropdown() {
  return DropdownButtonFormField<String>(
    value: _selectedRole,
    onChanged: (newValue) {
      setState(() {
        _selectedRole = newValue;
      });
    },
    items: [
      DropdownMenuItem(value: 'Membre', child: _buildDropdownItem('Membre', Icons.person)),
      DropdownMenuItem(value: 'Administrateur', child: _buildDropdownItem('Administrateur', Icons.admin_panel_settings)),
      DropdownMenuItem(value: 'Journaliste', child: _buildDropdownItem('Journaliste', Icons.edit)),
      DropdownMenuItem(value: 'Organisateur', child: _buildDropdownItem('Organisateur', Icons.event)),
    ],
    decoration: InputDecoration(
      labelText: 'Rôle',
      labelStyle: GoogleFonts.poppins(),
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    dropdownColor: Colors.white,
    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
    style: GoogleFonts.poppins(color: Colors.black),
  );
}

Widget _buildDropdownItem(String text, IconData icon) {
  return Row(
    children: [
      Icon(icon, color: Colors.black, size: 20),
      const SizedBox(width: 10),
      Text(
        text,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
      ),
    ],
  );
}
}
