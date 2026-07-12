import 'package:flutter/material.dart';
import '../model/Activity.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${activity.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text('Title: ${activity.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Description: ${activity.desc}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Date From: ${activity.dateFrom?.toString() ?? "N/A"}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Students: ${activity.stdList.join(", ")}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
