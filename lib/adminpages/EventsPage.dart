import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_app/adminpages/admin_dashboard.dart';

import 'Eventslist.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save event to Firestore
  Future<void> _saveEvent() async {
    if (_eventNameController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('noc_events').add({
        'event_name': _eventNameController.text,
        'start_date': _startDate,
        'end_date': _endDate,
        'created_at': Timestamp.now(),
      });
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text(
      'vénement créé avec succès!',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.green, 
    duration: const Duration(seconds: 3),  
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), 
    ),
    behavior: SnackBarBehavior.floating,  
    margin: const EdgeInsets.all(16),
  ),
);

      _eventNameController.clear();
      _locationController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Date picker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOCEvent',style: TextStyle(color: Colors.white),),
        backgroundColor:Colors.black, 
        elevation: 0, 
           actions: [
          _buildAppBarButton(
            context,
            label: "Tableau de bord",
            onPressed: () {
           Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            },
          ),
          _buildAppBarButton(
            context,
            label: "evenements",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Eventslist()),
              );
            },
          ),],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Nom de l’événement',
                labelStyle: const TextStyle(color: Colors.grey), 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Start Date
            ListTile(
              title: Text(
                _startDate == null
                    ? 'Date de début'
                    : DateFormat('yyyy-MM-dd').format(_startDate!),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 20),

            // End Date
            ListTile(
              title: Text(
                _endDate == null
                    ? 'Date de fin'
                    : DateFormat('yyyy-MM-dd').format(_endDate!),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 30),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Créer l’événement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
