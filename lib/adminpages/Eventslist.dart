import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_app/adminpages/EventsPage.dart';
import 'package:qr_app/adminpages/admin_dashboard.dart';


import 'dettailedEvent.dart'; // Import your detail page

class Eventslist extends StatefulWidget {
  const Eventslist({super.key});

  @override
  State<Eventslist> createState() => _EventslistState();
}

class _EventslistState extends State<Eventslist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentPage = 1;
  int _rowsPerPage = 5;

  Future<List<Map<String, dynamic>>> _getEvents() async {
    QuerySnapshot snapshot = await _firestore.collection('noc_events').get();
    List<Map<String, dynamic>> eventsList = [];

    for (var doc in snapshot.docs) {
      var eventData = doc.data() as Map<String, dynamic>;

      Timestamp? startDateTimestamp = eventData['start_date'] as Timestamp?;
      if (startDateTimestamp != null) {
        DateTime startDate = startDateTimestamp.toDate();
        String status = startDate.isBefore(DateTime.now()) ? 'inactif' : 'actif';

        eventsList.add({
          'event_name': eventData['event_name'] ?? 'Pas de nom',
          'start_date': startDate,
          'status': status,
        });
      } else {
        eventsList.add({
          'event_name': eventData['event_name'] ?? 'Pas de nom',
          'start_date': 'Pas de date',
          'status': 'inactif',
        });
      }
    }

    return eventsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOCEvent', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
          actions: [
          _buildAppBarButton(
            context,
            label: "Tableau de bord",
            onPressed: () {
          Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const  AdminDashboard()),
              );
            },
          ),
          _buildAppBarButton(
            context,
            label: "Crée un evenement",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const  CreateEventPage()),
              );
            },
          ),
          
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun événement disponible.'));
          }

          List<Map<String, dynamic>> events = snapshot.data!;

          int startIndex = (_currentPage - 1) * _rowsPerPage;
          int endIndex = startIndex + _rowsPerPage;
          List<Map<String, dynamic>> paginatedEvents = events.sublist(
            startIndex,
            endIndex > events.length ? events.length : endIndex,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.black),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Nom de l\'événement',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Date de début',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Statut',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    rows: paginatedEvents.map((event) {
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color>(
                            (states) => Colors.grey[200]!),
                        cells: [
                          DataCell(Text(
                            event['event_name'],
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          )),
                          DataCell(Text(
                            event['start_date'] is DateTime
                                ? (event['start_date'] as DateTime)
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]
                                : event['start_date'],
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          )),
                          DataCell(Text(
                            event['status'],
                            style: TextStyle(
                              fontSize: 16,
                              color: event['status'] == 'actif'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ],
                        onSelectChanged: (selected) {
                          if (selected != null && selected) {
                            // Navigate to the "DetailleEvenements" page and pass the event data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailleEvenements(eventData: event),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                    Text('Page $_currentPage'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: (startIndex + _rowsPerPage) < events.length
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
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
