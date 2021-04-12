import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Temporary {

  static Future<void> updateIncidentData() async {
    final list = await FirebaseFirestore.instance.collection("schools").get();
    for (var i = 0; i < list.docs.length; i++) {
      await updateIncidentDataSingle("schools/${list.docs[i].id}");
    }
  }

  static Future<void> updateIncidentDataSingle(String schoolId) async {
    final doc = FirebaseFirestore.instance.doc(schoolId);
    await doc.set({
      "incidents": {
        "positive": {},
        "negative": {},
      },
    }, SetOptions(merge: true));
    await doc.set({
      "incidents": {
        "negative": {
          "armedAssault": "Armed Assault",
          "autoAccidentInjury": "Auto Accident - Injury",
          "autoAccidentNonInjury": "Auto Accident - Non Injury",
          "boatAccidentInjury": "Boat Accident - Injury",
          "boatAccidentNonInjury": "Boat Accident - Non Injury",
          "excessiveNoise": "Excessive Noise",
          "fight": "Fight",
          "fire": "Fire",
          "intruderTrespass": "Intruder/Trespass",
          "maintenance": "Maintenance",
          "oilHazMatSpill": "Oil/Haz Mat Spill",
          "outstandingService": "Outstanding Service",
          "theft": "Theft",
          "threats": "Threats",
          "vandalism": "Vandalism",
        },
      },
    }, SetOptions(merge: true));
  }
}
