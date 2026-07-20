import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/earthquake_model.dart';

class EarthquakeService {
  final CollectionReference _dbCollection = FirebaseFirestore.instance
      .collection('earthquake');
 
  Stream<List<EarthquakeModel>> getEarthquakeStream() {
    return _dbCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EarthquakeModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

}
