import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../service/LogDataService.dart';

class SimpleLineChartDemoSol extends StatefulWidget {
  const SimpleLineChartDemoSol({super.key});

  @override
  State<SimpleLineChartDemoSol> createState() => _SimpleLineChartDemoSolState();
}

class _SimpleLineChartDemoSolState extends State<SimpleLineChartDemoSol> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _logStream;

  @override
  void initState() {
    super.initState();
    _logStream = FirebaseFirestore.instance
        .collection('server_logs')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _logStream,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No data server_logs'));
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.data!.docs;

            // call function
            final Map<String, double> timelineData =
                LogDataService.calculateDurationOverTime(docs);

            // get datetime to define value-Coor-X
            final List<String> sortedDates = timelineData.keys.toList();

            // convert map to x,y (FlSpot), x=index, y=avg of duration
            List<FlSpot> spots = [];
            for (int i = 0; i < sortedDates.length; i++) {
              String date = sortedDates[i];
              double avgDuration = timelineData[date] ?? 0.0;
              spots.add(FlSpot(i.toDouble(), avgDuration));
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'System Performance Trend (ms)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      minY: 1000,
                      maxY: 3500,
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),

                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              Colors.blueGrey.shade900,
                          getTooltipItems: (touchedSpots) =>
                              touchedSpots.map((barSpot) {
                                return LineTooltipItem(
                                  '${barSpot.y.toStringAsFixed(1)} ms',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                      // define label on Co-or-X, Y
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();

                              // Check value in boundary x, y
                              if (index >= 0 && index < sortedDates.length) {
                                return Text(
                                  sortedDates[index],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),

                      // define style of graph
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 4,
                          color: Colors.deepPurple,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.deepPurple.withOpacity(0.15),
                          ),
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
