import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String title;
  final String desc;
  final List<dynamic> stdList;
  final DateTime? dateFrom;

  // Constructor
  Activity({
    required this.id,
    required this.title,
    required this.desc,
    required this.stdList,
    this.dateFrom,
  });

  // Factory constructor: convert DocumentSnapshot จาก Firebase -> Object
  factory Activity.fromFirestore(DocumentSnapshot doc) {
    return Activity(
      id: doc.id,
      title: doc['title'] ?? 'activity name is not defined',
      desc: doc['desc'] ?? '',
      stdList: doc['stdlist'] ?? [],
      dateFrom: (doc['datefrom'] as Timestamp?)?.toDate(),
    );
  }
}
