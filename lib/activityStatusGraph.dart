import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityStatusGraph extends StatefulWidget {
  @override
  _StatusGraphState createState() => _StatusGraphState();
}

class _StatusGraphState extends State<ActivityStatusGraph> {
  Map<String, int> activityStatusCount = {
    'Pending': 0,
    'Completed': 0,
    'LateDone': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      FirebaseFirestore.instance
          .collection('activities')
          .where('email', isEqualTo: userEmail)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          setState(() {
            String status = doc['status'];
            if (activityStatusCount.containsKey(status)) {
              activityStatusCount[status] = activityStatusCount[status]! + 1;
            }
          });
        });
      }).catchError((error) {
        print('Error fetching activities: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Status Graph'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Center(
                child: PieChart(
                  PieChartData(
                    sections: _getSections(),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, PieTouchResponse? response) {}),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Pending', Colors.yellow),
                _buildLegendItem('Completed', Colors.green),
                _buildLegendItem('LateDone', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          SizedBox(width: 8),
          Text(
            '$status: ${activityStatusCount[status]}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return activityStatusCount.entries.map((entry) {
      final String status = entry.key;
      final int count = entry.value;

      Color color;
      switch (status) {
        case 'Pending':
          color = Colors.yellow;
          break;
        case 'Completed':
          color = Colors.green;
          break;
        case 'LateDone':
          color = Colors.red;
          break;
        default:
          color = Colors.grey;
      }

      return PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: '',
        radius: 80,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
      );
    }).toList();
  }
}
