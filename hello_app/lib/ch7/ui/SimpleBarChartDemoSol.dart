import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../service/LogDataService.dart';

class SimpleBarChartDemoSol extends StatefulWidget {
  const SimpleBarChartDemoSol({super.key});

  @override
  State<SimpleBarChartDemoSol> createState() => _SimpleBarChartDemoSolState();
}

class _SimpleBarChartDemoSolState extends State<SimpleBarChartDemoSol> {
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
              return const Center(child: Text('no data in server_logs'));
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.data!.docs;
            final Map<String, double> averages =
                LogDataService.calculateAverageDuration(docs);

            double authTime = averages['auth-service'] ?? 0.0;
            double userTime = averages['user-service'] ?? 0.0;
            double paymentTime = averages['payment-service'] ?? 0.0;
            double gatewayTime = averages['api-gateway'] ?? 0.0;
            double notifyTime = averages['notification-service'] ?? 0.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avg Response Duration by Service (ms)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 3000,
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),

                      // paint border here
                      borderData: FlBorderData(
                        show: true, // enable border
                        border: Border.all(
                          color: Colors.blueGrey.shade700,
                          width: 1.5,
                        ),
                      ),

                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey.shade900,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final services = [
                              'auth-service',
                              'user-service',
                              'payment-service',
                              'api-gateway',
                              'notification-service',
                            ];

                            return BarTooltipItem(
                              '${services[group.x]}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '${rod.toY.toStringAsFixed(1)} ms',
                                  style: const TextStyle(
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

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
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 11),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text(
                                    'auth',
                                    style: TextStyle(fontSize: 11),
                                  );
                                case 1:
                                  return const Text(
                                    'user',
                                    style: TextStyle(fontSize: 11),
                                  );
                                case 2:
                                  return const Text(
                                    'payment',
                                    style: TextStyle(fontSize: 11),
                                  );
                                case 3:
                                  return const Text(
                                    'api-gateway',
                                    style: TextStyle(fontSize: 11),
                                  );
                                case 4:
                                  return const Text(
                                    'notification',
                                    style: TextStyle(fontSize: 11),
                                  );
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        _makeBarGroup(0, authTime),
                        _makeBarGroup(1, userTime),
                        _makeBarGroup(2, paymentTime),
                        _makeBarGroup(3, gatewayTime),
                        _makeBarGroup(4, notifyTime),
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

  BarChartGroupData _makeBarGroup(int x, double yValue) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: yValue,
          color: Colors.indigo.shade700,
          width: 22,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
      ],
    );
  }
}
