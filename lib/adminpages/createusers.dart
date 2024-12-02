// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_app/adminpages/admin_dashboard.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _role = 'membre'; // Default role
  String _civilite = 'M'; // Default civilité
  String? _qrCodeData;

  // Define the roles
  List<String> roles = ['membre', 'journaliste', 'organisateur', 'administrateur'];
  // Define the civilité options
  List<String> civiliteOptions = ['M', 'Mme'];

  // Pagination variables
  int _currentPage = 1;
  int _rowsPerPage = 5;
  late List<QueryDocumentSnapshot> _users = [];
  late int _totalRows = 0;
  var _selectedUser;

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check if email already exists in Firestore
        var existingUser = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailController.text)
            .get();

        if (existingUser.docs.isNotEmpty) {
          // Email already in use, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cet email est déjà utilisé. Veuillez en choisir un autre.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Save the user data to Firestore
        await FirebaseFirestore.instance.collection('users').add({
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'civilite': _civilite,
          'dob': _dobController.text,
          'role': _role,
          'email': _emailController.text,
        });

        // Generate QR code data
        String qrData = "Nom: ${_nomController.text}, Prenom: ${_prenomController.text}, Email: ${_emailController.text}";
        setState(() {
          _qrCodeData = qrData; // Store the generated QR code data
        });

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Utilisateur créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error creating user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de l\'utilisateur.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fetch users with pagination
  Future<void> _fetchUsers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('nom')
        .startAfter([(_currentPage - 1) * _rowsPerPage])
        .limit(_rowsPerPage)
        .get();

    setState(() {
      _users = querySnapshot.docs;
      _totalRows = querySnapshot.size;
    });
  }

void _showEditUserForm(QueryDocumentSnapshot user) {
  final TextEditingController editNomController =
      TextEditingController(text: user['nom']);
  final TextEditingController editPrenomController =
      TextEditingController(text: user['prenom']);
  final TextEditingController editEmailController =
      TextEditingController(text: user['email']);
  final TextEditingController editDobController =
      TextEditingController(text: user['dob']);
  String editRole = user['role'];
  String editCivilite = user['civilite'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Modifier l\'utilisateur',
                  style: GoogleFonts.poppins(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: editNomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextFormField(
                  controller: editPrenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                ),
                DropdownButtonFormField<String>(
                  value: editCivilite,
                  decoration: InputDecoration(labelText: 'Civilité'),
                  onChanged: (newValue) {
                    setState(() {
                      editCivilite = newValue!;
                    });
                  },
                  items: civiliteOptions.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                ),
                TextFormField(
                  controller: editDobController,
                  decoration: InputDecoration(
                    labelText: 'Date de naissance',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
                TextFormField(
                  controller: editEmailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                DropdownButtonFormField<String>(
                  value: editRole,
                  decoration: InputDecoration(labelText: 'Rôle'),
                  onChanged: (newValue) {
                    setState(() {
                      editRole = newValue!;
                    });
                  },
                  items: roles.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (editNomController.text.isEmpty ||
                          editPrenomController.text.isEmpty ||
                          editEmailController.text.isEmpty ||
                          editDobController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez remplir tous les champs!')),
                        );
                        return;
                      }

                      // Update the user in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)  // Using the document ID
                          .update({
                        'nom': editNomController.text,
                        'prenom': editPrenomController.text,
                        'civilite': editCivilite,
                        'dob': editDobController.text,
                        'role': editRole,
                        'email': editEmailController.text,
                      });

                      // Optionally update QR code or any other necessary UI updates
                      String updatedQrData = 
                          "Nom: ${editNomController.text}, Prenom: ${editPrenomController.text}, Email: ${editEmailController.text}";
                      setState(() {
                        _qrCodeData = updatedQrData;
                        _fetchUsers(); // Refresh the user list
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Utilisateur modifié avec succès!')),
                      );

                      Navigator.pop(context);  // Close the modal

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de la modification.')),
                      );
                    }
                  },
                  child: Text('Enregistrer'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Load users when the page is loaded
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "NocEvent",
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
      ),
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      actions: [
        _buildAppBarButton(
          context,
          label: "Tableau de bord",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          },
        ),
      ],
    ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomController,
                      decoration: InputDecoration(labelText: 'Nom'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _prenomController,
                      decoration: InputDecoration(labelText: 'Prénom'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prénom';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _civilite,
                      decoration: InputDecoration(labelText: 'Civilité'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _civilite = newValue!;
                        });
                      },
                      items: civiliteOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        labelText: 'Date de naissance',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une date de naissance';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: InputDecoration(labelText: 'Rôle'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _role = newValue!;
                        });
                      },
                      items: roles.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _createUser,
                      child: Text("Valider", style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Handle the cancel action here
                      },
                      child: Text("Annuler", style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (_qrCodeData != null)
                QrImageView(
                  data: _qrCodeData!,
                  size: 200,
                  gapless: false,
                ),
              const SizedBox(height: 20),
              // Display Users Table
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  _users = snapshot.data!.docs;

                  return Column(
                    children: [
                      DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.black, // Set black background for heading row
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Nom',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white, // White text color for column labels
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Prénom',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Role',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Date de Naissance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Civilité',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Actions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        rows: _users.map((user) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected == true) {
                                setState(() {
                                  // Save selected user for further actions
                                  _selectedUser = user;
                                  _qrCodeData = "Nom: ${user['nom']}, Prénom: ${user['prenom']}, Email: ${user['email']}";
                                });
                                showPopupCard(context, user.data() as Map<String, dynamic>, _qrCodeData!);
                              }
                            },
                            selected: _selectedUser?.id == user.id,
                            cells: [
                              DataCell(Text(user['nom'])),
                              DataCell(Text(user['prenom'])),
                              DataCell(Text(user['email'])),
                              DataCell(Text(user['role'])),
                              DataCell(Text(user['dob'])),
                              DataCell(Text(user['civilite'])),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _editUser(user);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteUser(user.id);
                                    },
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  // Method to handle user edit
  void _editUser(QueryDocumentSnapshot user) {
    setState(() {
      _selectedUser = user;
      _nomController.text = user['nom'];
      _prenomController.text = user['prenom'];
      _dobController.text = user['dob'];
      _emailController.text = user['email'];
      _role = user['role'];
      _civilite = user['civilite'];
    });

    showPopupCard(context, user.data() as Map<String, dynamic>, _qrCodeData!);
  }

  // Method to handle user deletion
  void _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur supprimé')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression')));
    }
  }


void showPopupCard(BuildContext context, Map<String, dynamic> user, String _qrCodeData) {
  String firstName = user['nom'] ?? 'N/A'; // Use 'nom' for first name
  String lastName = user['prenom'] ?? 'N/A'; // Use 'prénom' for last name
  
  String qrData = 'Nom: $firstName, Prénom: $lastName, Email: ${user['email']}'; // Construct QR data

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 16,
        child: Container(
          padding: EdgeInsets.all(20),
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Déttaille de l''utilsateur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Divider(),
              SizedBox(height: 10),
              Text(
                'First Name: $firstName',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Last Name: $lastName',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Date of Birth: ${user['dob'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Email: ${user['email'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Role: ${user['role'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
          
              Container(
                height: 200,
                width: double.infinity,
                child: QrImageView(
                  data: qrData, // Pass the dynamic data to generate the QR code
                  size: 200.0, // Size of the QR code image
                  gapless: false, // To show a clean QR code image without gaps
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
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