import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../service/LogDataService.dart';

class SimplePieChartDemoSol extends StatefulWidget {
  const SimplePieChartDemoSol({super.key});

  @override
  State<SimplePieChartDemoSol> createState() => _SimplePieChartDemoSolState();
}

class _SimplePieChartDemoSolState extends State<SimplePieChartDemoSol> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _logStream;

  final Map<String, Color> _levelColors = {
    'INFO': Colors.green.shade600,
    'WARN': Colors.amber.shade600,
    'ERROR': Colors.orange.shade700,
    'FATAL': Colors.red.shade700,
  };

  int? _touchedIndex;

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
              return const Center(child: Text('No data in server_logs'));
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.data!.docs;

            final Map<String, int> logCounts = LogDataService.aggregateLogData(
              docs,
            );

            final entries = logCounts.entries.toList();
            final entriesWithCount = entries.where((e) => e.value > 0).toList();

            List<PieChartSectionData> sections = [];
            for (int i = 0; i < entriesWithCount.length; i++) {
              final level = entriesWithCount[i].key;
              final count = entriesWithCount[i].value;

              final isTouched = _touchedIndex == i;
              sections.add(
                PieChartSectionData(
                  value: count.toDouble(),
                  title: '$level\n($count)',
                  color: _levelColors[level] ?? Colors.grey,
                  radius: isTouched ? 72 : 60,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 13 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: isTouched
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${count} hits',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        )
                      : null,
                  badgePositionPercentageOffset: .98,
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Log System Status Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 48,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = null;
                                  } else {
                                    final idx = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                    _touchedIndex = (idx != null && idx >= 0)
                                        ? idx
                                        : null;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _touchedIndex != null &&
                                      _touchedIndex! < entriesWithCount.length
                                  ? entriesWithCount[_touchedIndex!].key
                                  : 'All Levels',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _touchedIndex != null &&
                                      _touchedIndex! < entriesWithCount.length
                                  ? '${entriesWithCount[_touchedIndex!].value} hits'
                                  : '${logCounts.values.fold<int>(0, (a, b) => a + b)} hits',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
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
