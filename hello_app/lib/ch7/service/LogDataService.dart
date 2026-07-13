import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LogDataService {
  // 1. Count error status: Pie Chart
  static Map<String, int> aggregateLogData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    Map<String, int> counts = {'INFO': 0, 'WARN': 0, 'ERROR': 0, 'FATAL': 0};
    for (var doc in docs) {
      final dynamic levelData = doc.data()['level'];
      if (levelData != null) {
        String level = levelData.toString();
        if (counts.containsKey(level)) {
          counts[level] = counts[level]! + 1;
        }
      }
    }
    return counts;
  }

  // 2. Barchart: Find avg of Duration, group by Service name
  static Map<String, double> calculateAverageDuration(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    Map<String, List<int>> serviceDurations = {};
    for (var doc in docs) {
      final data = doc.data();
      final String? service = data['service'];
      final dynamic durationData = data['duration'];

      if (service != null && durationData != null) {
        final int duration = (durationData as num).toInt();
        serviceDurations.putIfAbsent(service, () => []).add(duration);
      }
    }

    Map<String, double> averages = {};
    serviceDurations.forEach((service, durations) {
      double avg = durations.reduce((a, b) => a + b) / durations.length;
      averages[service] = avg;
    });
    return averages;
  }

  // LineChart: find avg Duration, group by datetime
  static Map<String, double> calculateDurationOverTime(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    Map<String, List<int>> timeDurations = {};

    // เรียงลำดับตามเวลาจริงจากเก่าไปใหม่ก่อนประมวลผล
    List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedDocs = List.from(
      docs,
    );
    sortedDocs.sort((a, b) {
      String timeA = a.data()['timestamp']?.toString() ?? '';
      String timeB = b.data()['timestamp']?.toString() ?? '';
      return timeA.compareTo(timeB);
    });

    for (var doc in sortedDocs) {
      final data = doc.data();
      final String? timestampStr = data['timestamp'];
      final dynamic durationData = data['duration'];

      if (timestampStr != null && durationData != null) {
        final int duration = (durationData as num).toInt();
        try {
          // convert ISO Timestamp as "07-04" (dd-mm)
          DateTime dt = DateTime.parse(timestampStr).toLocal();
          String formattedDate = DateFormat('MM-dd').format(dt);

          timeDurations.putIfAbsent(formattedDate, () => []).add(duration);
        } catch (e) {}
      }
    }

    Map<String, double> timelineAverages = {};
    timeDurations.forEach((date, durations) {
      double avg = durations.reduce((a, b) => a + b) / durations.length;
      timelineAverages[date] = avg;
    });

    return timelineAverages; // ผลลัพธ์จะได้ เช่น {'06-17': 1689.0, '07-04': 1241.0}
  }
}
