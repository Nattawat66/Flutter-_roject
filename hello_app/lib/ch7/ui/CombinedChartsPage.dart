import 'package:flutter/material.dart';
import 'SimpleBarChartDemoSol.dart';
import 'SimpleLineChartDemoSol.dart';
import 'SimplePieChartDemoSol.dart';

class CombinedChartsPage extends StatefulWidget {
  const CombinedChartsPage({super.key});

  @override
  State<CombinedChartsPage> createState() => _CombinedChartsPageState();
}

class _CombinedChartsPageState extends State<CombinedChartsPage> {
  void _showFullScreenChart(Widget chart, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.maxFinite,
                      height: 500,
                      child: chart,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardWrapper({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () => _showFullScreenChart(child, title),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.open_in_full, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Combined Charts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardWrapper(
              title: 'System Performance Trend (Line)',
              child: const SimpleLineChartDemoSol(),
            ),
            _cardWrapper(
              title: 'Avg Response Duration by Service (Bar)',
              child: const SimpleBarChartDemoSol(),
            ),
            _cardWrapper(
              title: 'Log System Status Distribution (Pie)',
              child: const SimplePieChartDemoSol(),
            ),
          ],
        ),
      ),
    );
  }
}
