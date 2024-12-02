import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_dashboard.dart';

class Staticsdashboard extends StatefulWidget {
  const Staticsdashboard({super.key});

  @override
  State<Staticsdashboard> createState() => _StaticsdashboardState();
}

class _StaticsdashboardState extends State<Staticsdashboard> with SingleTickerProviderStateMixin {
  int totalUsers = 0;
  int presentUsers = 0;
  int absentUsers = 0;
  List<Map<String, dynamic>> votesData = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
    fetchVoteData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<void> fetchAttendanceData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot userSnapshot = await firestore.collection('users').get();
      int total = userSnapshot.docs.length;

      QuerySnapshot attendanceSnapshot = await firestore.collection('attendance').get();

      int present = attendanceSnapshot.docs
          .where((doc) => (doc['present'] as bool?) ?? false)
          .length;

      int absent = total - present;

      setState(() {
        totalUsers = total;
        presentUsers = present;
        absentUsers = absent;
      });

      _animationController.forward();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> fetchVoteData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot voteSnapshot = await firestore.collection('votes').get();
      debugPrint("Fetched ${voteSnapshot.docs.length} vote documents");

      setState(() {
        votesData = voteSnapshot.docs.map((doc) {
          var votes = doc['votes'] as Map<String, dynamic>;

          int totalVotes = votes.values.fold(0, (sum, voteCount) {
            return sum + (voteCount is int ? voteCount : (voteCount is num ? voteCount.toInt() : 0));
          });

          return {
            "question": doc['question'],
            "totalVotes": totalVotes,
            "votes": votes,
          };
        }).toList();
      });

      for (var voteData in votesData) {
        debugPrint("Question: ${voteData['question']}");
        debugPrint("Total Votes: ${voteData['totalVotes']}");
        debugPrint("Votes: ${voteData['votes']}");
      }
    } catch (e) {
      debugPrint("Error fetching votes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // const Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Statistics Dashboard",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2,
                      children: [
                        buildStatCard(
                          title: "Total Users",
                          count: totalUsers,
                          color: Colors.blue,
                          icon: Icons.people,
                        ),
                        buildStatCard(
                          title: "Present Users",
                          count: presentUsers,
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                        buildStatCard(
                          title: "Absent Users",
                          count: absentUsers,
                          color: Colors.red,
                          icon: Icons.cancel,
                        ),
                        buildVoteResultCard(),
                        buildPieChart(),
                        buildBarChart(),
                         buildVoteBarChart(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        debugPrint("$title card tapped!");
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(icon, size: 30, color: Colors.white),
          ],
        ),
      ),
    );
  }
Widget buildVoteResultCard() {
  int totalVotes = votesData.fold(0, (sum, vote) => sum + (vote['votes'] as Map).values.fold(0, (s, v) => s + (v is int ? v : 0)));

  return GestureDetector(
    onTap: () {
      debugPrint("Vote Results card tapped!");
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vote Results",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Total Votes: $totalVotes",
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Wrapping the content in a SingleChildScrollView to avoid overflow
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: votesData.map((vote) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(
                      "${vote['question']}: ${vote['totalVotes']} votes",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget buildPieChart() {
    double total = totalUsers.toDouble();
    double presentPercentage = total == 0 ? 0 : (presentUsers / total) * 100;
    double absentPercentage = total == 0 ? 0 : (absentUsers / total) * 100;

    return _buildChartContainer(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: presentPercentage * _animation.value,
                  color: Colors.green,
                  title: '${(presentPercentage * _animation.value).toStringAsFixed(1)}%',
                  radius: 30,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  value: absentPercentage * _animation.value,
                  color: Colors.red,
                  title: '${(absentPercentage * _animation.value).toStringAsFixed(1)}%',
                  radius: 30,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildBarChart() {
    return _buildChartContainer(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return BarChart(
            BarChartData(
              maxY: totalUsers.toDouble(),
              barGroups: [
                _buildBarData(0, totalUsers.toDouble()),
                _buildBarData(1, presentUsers.toDouble()),
                _buildBarData(2, absentUsers.toDouble()),
              ],
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
            ),
          );
        },
      ),
    );
  }

  BarChartGroupData _buildBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y * _animation.value,
          color: x == 0
              ? Colors.blue
              : x == 1
                  ? Colors.green
                  : Colors.red,
          width: 25,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildChartContainer({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
  Widget buildVoteBarChart() {
  if (votesData.isEmpty) {
    return Center(
      child: Text(
        "No voting data available",
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
    );
  }

  return _buildChartContainer(
    child: AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Determine the maximum votes across all options
        double maxVotes = votesData.fold(
          0,
          (maxValue, vote) {
            int highestOptionVote = (vote['votes'] as Map<String, dynamic>)
                .values
                .fold(0, (sum, count) => count is int ? sum + count : sum);
            return highestOptionVote > maxValue
                ? highestOptionVote.toDouble()
                : maxValue;
          },
        );

        return BarChart(
          BarChartData(
            maxY: maxVotes * 1.2, // Add some padding for better visuals
            barGroups: votesData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> vote = entry.value;
              Map<String, dynamic> voteCounts = vote['votes'];

              return BarChartGroupData(
                x: index,
                barRods: voteCounts.entries.map((optionEntry) {
                  int count = optionEntry.value;
                  return BarChartRodData(
                    toY: count.toDouble() * _animation.value,
                    width: 20,
                    color: Colors.primaries[index % Colors.primaries.length],
                    borderRadius: BorderRadius.circular(6),
                  );
                }).toList(),
                showingTooltipIndicators: List.generate(
                    voteCounts.length, (i) => i), // Show tooltips for all
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= votesData.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        votesData[index]['question'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                top: BorderSide.none,
                right: BorderSide.none,
                bottom: BorderSide(color: Colors.black12),
                left: BorderSide(color: Colors.black12),
              ),
            ),
            gridData: FlGridData(show: true),
          ),
        );
      },
    ),
  );
}

}
