import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuiviUtilisateur extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String eventName;

  const SuiviUtilisateur({Key? key, required this.eventData, required this.eventName}) : super(key: key);

  @override
  _SuiviUtilisateurState createState() => _SuiviUtilisateurState();
}

class _SuiviUtilisateurState extends State<SuiviUtilisateur> {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> selectedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSelectedUsers();
  }

  Future<void> _fetchSelectedUsers() async {
    try {
      final eventQuerySnapshot = await FirebaseFirestore.instance
          .collection('noc_events')
          .where('event_name', isEqualTo: widget.eventName)
          .get();

      if (eventQuerySnapshot.docs.isNotEmpty) {
        final eventDoc = eventQuerySnapshot.docs.first;

        if (eventDoc.exists && eventDoc.data().containsKey('users')) {
          List userIds = eventDoc['users'];
          for (String userId in userIds) {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
            if (userDoc.exists) {
              selectedUsers.add({
                'id': userDoc.id,
                'name': userDoc['nom'] ?? 'Nom inconnu',
                'email': userDoc['email'] ?? 'Pas d\'email',
                'dob': userDoc['dob'] ?? 'Pas de date de naissance',
                'role': userDoc['role'] ?? 'Pas de rôle',
              });
            }
          }
        }
      }
    } catch (e) {
      print("Erreur lors de la récupération des utilisateurs sélectionnés : $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchAllUsers() async {
    try {
      final userDocs = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        allUsers = userDocs.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['nom'] ?? 'Nom inconnu',
            'email': doc['email'] ?? 'Pas d\'email',
            'dob': doc['dob'] ?? 'Pas de date de naissance',
            'role': doc['role'] ?? 'Pas de rôle',
          };
        }).toList();
      });
    } catch (e) {
      print("Erreur lors de la récupération de tous les utilisateurs : $e");
    }
  }

  void _showAddUsersDialog() async {
    await _fetchAllUsers();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Sélectionner les utilisateurs",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allUsers.map((user) {
                final isSelected = selectedUsers.any((selected) => selected['id'] == user['id']);
                return CheckboxListTile(
                  title: Text(user['name'], style: TextStyle(fontSize: 16)),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true && !isSelected) {
                        selectedUsers.add(user);
                      } else if (value == false && isSelected) {
                        selectedUsers.removeWhere((selected) => selected['id'] == user['id']);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annuler", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final userIds = selectedUsers.map((user) => user['id']).toList();
                  final eventQuerySnapshot = await FirebaseFirestore.instance
                      .collection('noc_events')
                      .where('event_name', isEqualTo: widget.eventName)
                      .get();
                  if (eventQuerySnapshot.docs.isNotEmpty) {
                    final eventDoc = eventQuerySnapshot.docs.first;
                    await FirebaseFirestore.instance.collection('noc_events').doc(eventDoc.id).update({
                      'users': userIds,
                    });
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  print("Erreur lors de la sauvegarde des utilisateurs sélectionnés : $e");
                }
              },
              child: Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeUserFromEvent(String userId) async {
    setState(() {
      selectedUsers.removeWhere((user) => user['id'] == userId);
    });
    try {
      final eventQuerySnapshot = await FirebaseFirestore.instance
          .collection('noc_events')
          .where('event_name', isEqualTo: widget.eventName)
          .get();

      if (eventQuerySnapshot.docs.isNotEmpty) {
        final eventDoc = eventQuerySnapshot.docs.first;
        await FirebaseFirestore.instance.collection('noc_events').doc(eventDoc.id).update({
          'users': FieldValue.arrayRemove([userId]),
        });
      }
    } catch (e) {
      print("Erreur lors de la suppression de l'utilisateur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suivi Utilisateur',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _showAddUsersDialog,
                      child: Text("Ajouter des utilisateurs", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: DataTable(
                        border: TableBorder.all(color: Colors.black, width: 1),
                        columns: [
                          DataColumn(label: Text("Nom", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Date de naissance", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Rôle", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: selectedUsers.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(Text(user['name'])),
                              DataCell(Text(user['email'])),
                              DataCell(Text(user['dob'])),
                              DataCell(Text(user['role'])),
                              DataCell(IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeUserFromEvent(user['id']),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
