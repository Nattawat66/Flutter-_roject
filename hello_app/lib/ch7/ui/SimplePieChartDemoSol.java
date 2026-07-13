import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimplePieChartDemoSol extends StatefulWidget {
  const SimplePieChartDemoSol({super.key});

  @override
  State<SimplePieChartDemoSol> createState() => _AggregateChartDemoState();
}

class _AggregateChartDemoState extends State<SimplePieChartDemoSol> {
  Future<Map<String, int>> _getAggregatedLogs() async {
    final collection = FirebaseFirestore.instance.collection('server_logs');

    final infoQuery = await collection
        .where('level', isEqualTo: 'INFO')
        .count()
        .get();
    final warnQuery = await collection
        .where('level', isEqualTo: 'WARN')
        .count()
        .get();
    final errorQuery = await collection
        .where('level', isEqualTo: 'ERROR')
        .count()
        .get();
    final fatalQuery = await collection
        .where('level', isEqualTo: 'FATAL')
        .count()
        .get();

    return {
      'INFO': infoQuery.count ?? 0,
      'WARN': warnQuery.count ?? 0,
      'ERROR': errorQuery.count ?? 0,
      'FATAL': fatalQuery.count ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, int>>(
		//2. get aggregation
        future: _getAggregatedLogs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

			//3. get data from firebase
          final logCounts = snapshot.data!;
          int info = logCounts['INFO']!;
          int warn = logCounts['WARN']!;
          int error = logCounts['ERROR']!;
          int fatal = logCounts['FATAL']!;

          /* int total = info + warn + error + fatal;

          String toPercent(int count) {
            if (total == 0) return '0%';
            //'${ ... }%' ex. 70.0 -> '70.0%'
            return '${((count / total) * 100).toStringAsFixed(1)}%';
          } */

			//4 display pieChart 
          return Center(
            child: SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: 4,
                  sections: [
                    PieChartSectionData(
                      value: info.toDouble(),
                      title: 'INFO ($info)',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: warn.toDouble(),
                      title: 'WARN ($warn)',
                      color: Colors.orange,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: error.toDouble(),
                      title: 'ERROR ($error)',
                      color: Colors.redAccent,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: fatal.toDouble(),
                      title: 'FATAL ($fatal)',
                      color: Colors.purple,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
