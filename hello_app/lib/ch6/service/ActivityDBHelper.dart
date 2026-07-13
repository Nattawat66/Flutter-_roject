import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Activity.dart';

class ActivityDBHelper {
  static final FirebaseFirestore getdb = FirebaseFirestore.instance;

  static Stream<List<Activity>> getActivitiesStream() {
    return FirebaseFirestore.instance.collection('activity').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
    });
  } //func

  static Future<void> deleteActivity(String docId) async {
    await FirebaseFirestore.instance.collection("activity").doc(docId).delete();
  }

  static Future<void> addActivity(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('activity').add(data);
  }

  static Future<void> updateActivity(String docId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('activity').doc(docId).update(data);
  }
}//class

