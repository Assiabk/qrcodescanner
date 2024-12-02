import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class VotingPage extends StatefulWidget {
  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  TextEditingController _questionController = TextEditingController();
  TextEditingController _optionController = TextEditingController();
  List<String> _options = [];

  // Method to add options to the list
  void _addOption() {
    if (_optionController.text.isNotEmpty) {
      setState(() {
        _options.add(_optionController.text);
        _optionController.clear();
      });
    }
  }

  // Method to save question and options to Firebase
  void _saveVote() async {
    if (_questionController.text.isNotEmpty && _options.isNotEmpty) {
      try {
        FirebaseFirestore.instance.collection('votes').add({
          'question': _questionController.text,
          'options': _options,
          'votes': List<int>.filled(_options.length, 0),
        });

        setState(() {
          _questionController.clear();
          _options.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vote saved successfully!'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving vote.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // Method to vote for an option
  void _voteForOption(String questionId, int index) async {
    try {
      await FirebaseFirestore.instance.collection('votes').doc(questionId).update({
        'votes.$index': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Vote registered!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error registering vote.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Display question and options
  Widget _buildVoteCard(DocumentSnapshot doc) {
    List<dynamic> options = doc['options'];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc['question'],
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            ...options.asMap().entries.map((entry) {
              int idx = entry.key;
              String option = entry.value;
              return GestureDetector(
                onTap: () => _voteForOption(doc.id, idx),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Build the main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nocevent Vote',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('votes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No votes available.',
                        style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) => _buildVoteCard(doc)).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
