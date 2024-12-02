import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> _getTotalMembers() {
    return _firestore.collection('members').snapshots().map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getPresentMembers() {
    return _firestore.collection('attendance').where('present', isEqualTo: true).snapshots().map((snapshot) => snapshot.docs.length);
  }

  Stream<List<DocumentSnapshot>> _getAllMembers() {
    return _firestore.collection('members').snapshots().map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Wrap the entire content in SingleChildScrollView
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsRow(),
              SizedBox(height: 30),
              _buildChartContainer(_buildPieChart()),
              SizedBox(height: 30),
              _buildMembersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildStatisticsRow() {
    return Row(
      children: [
        _buildStatisticsContainer('Membres Totaux', _getTotalMembers(), Colors.blueAccent),
        SizedBox(width: 16),
        _buildStatisticsContainer('Membres Présents', _getPresentMembers(), Colors.greenAccent),
      ],
    );
  }

  Widget _buildStatisticsContainer(String title, Stream<int> stream, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 4)),
          ],
        ),
        child: StreamBuilder<int>(
          stream: stream,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  '${snapshot.data ?? 0}',
                  style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartContainer(Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: chart,
    );
  }

  Widget _buildPieChart() {
    return StreamBuilder<int>(
      stream: _getTotalMembers(),
      builder: (context, totalSnapshot) {
        if (!totalSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<int>(
          stream: _getPresentMembers(),
          builder: (context, presentSnapshot) {
            if (!presentSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final double total = totalSnapshot.data!.toDouble();
            final double present = presentSnapshot.data!.toDouble();
            final double absent = total - present;
            final double presentPercentage = (present / total) * 100;
            final double absentPercentage = (absent / total) * 100;

            return Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: Colors.greenAccent,
                          value: present,
                          title: '',
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        PieChartSectionData(
                          color: Colors.redAccent,
                          value: absent,
                          title: '',
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                      ],
                      sectionsSpace: 6,
                      centerSpaceRadius: 45,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem('Présents', Colors.greenAccent, present.toInt()),
                    _buildLegendItem('Absents', Colors.redAccent, absent.toInt()),
                  ],
                ),
                SizedBox(height: 16),
                _buildBarChart(presentPercentage, absentPercentage),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBarChart(double presentPercentage, double absentPercentage) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Présents',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: presentPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    color: Colors.greenAccent,
                    minHeight: 10,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${presentPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 199, 183, 183)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Absents',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: absentPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    color: Colors.redAccent,
                    minHeight: 10,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${absentPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 199, 183, 183)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '$label : $value',
          style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 199, 183, 183), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // New Widget to display all members
  Widget _buildMembersList() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _getAllMembers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final members = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index].data() as Map<String, dynamic>;
            final name = member['fullname'] ?? 'Inconnu';
            final contact = member['contact'] ?? 'Pas de contact';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(contact),
                leading: Icon(Icons.person, color: Colors.black),
              ),
            );
          },
        );
      },
    );
  }
}
