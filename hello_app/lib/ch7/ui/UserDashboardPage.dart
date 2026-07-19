import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('User_info').get();
      final List<dynamic> data = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _allUsers = data;
        _filteredUsers = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading Firebase data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _allUsers.where((user) {
        final String firstName = user['firstName']?.toLowerCase() ?? '';
        final String lastName = user['lastName']?.toLowerCase() ?? '';
        final String department = user['department']?.toLowerCase() ?? '';
        final String searchLower = query.toLowerCase();
        
        return firstName.contains(searchLower) || 
               lastName.contains(searchLower) || 
               department.contains(searchLower);
      }).toList();
    });
  }

  Map<String, int> _getDepartmentDistribution() {
    Map<String, int> distribution = {};
    for (var user in _filteredUsers) {
      final department = user['department'] ?? 'Unknown';
      distribution[department] = (distribution[department] ?? 0) + 1;
    }
    return distribution;
  }

  final List<Color> _chartColors = [
    Colors.blue.shade400,
    Colors.red.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.amber.shade400,
    Colors.pink.shade400,
    Colors.cyan.shade400,
    Colors.indigo.shade400,
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final deptData = _getDepartmentDistribution();
    final entries = deptData.entries.toList();
    
    // Sort by count descending
    entries.sort((a, b) => b.value.compareTo(a.value));

    List<PieChartSectionData> pieSections = [];
    for (int i = 0; i < entries.length; i++) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 100.0 : 80.0;
      
      final entry = entries[i];
      final color = _chartColors[i % _chartColors.length];

      pieSections.add(
        PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${entry.value}',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${entry.key}\n${entry.value} users',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 1.1,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Department Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Name or Department',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text("No data found"))
                : Card(
                    margin: const EdgeInsets.all(16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Department Distribution',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Users: ${_filteredUsers.length}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: pieSections,
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        _touchedIndex = null;
                                        return;
                                      }
                                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: List.generate(entries.length, (index) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: _chartColors[index % _chartColors.length],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    entries[index].key,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
