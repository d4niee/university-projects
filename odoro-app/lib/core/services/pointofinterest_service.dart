import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/models/pointofinterest_model.dart';
import 'package:odoro/core/api/firebase_api.dart';
/*
handles point of interest database interactions
 */
class PointOfInterestService {
  late final FirebaseApi db;

  PointOfInterestService() {
    db = FirebaseApi(collectionPath: FirebaseApi.pointsOfInterest);
  }
  /*
  creates a new point of interest to show on the map
  returns the newly created point of interest -> necessary?
   */
  Future<String> createPointOfInterest(PointOfInterest pointOfInterest) async {
    final id = await db.addDocument(pointOfInterest.toJson())
        .then((docRef) {
          print("Generated id: ${docRef.id}");
          final id = docRef.id;
          return id;
        })
        .onError((error, stacktrace) {
          print(stacktrace);
          print(error);
          return error.toString();
        });
    return id;
  }

  /*
  updates a point of interest on the map
   */
  Future<void> updatePointOfInterestById(PointOfInterest pointOfInterest) async {
    await db.updateDocument(pointOfInterest.toJson(), pointOfInterest.markerId)
      .then((_) => print("PoI updated"))
      .onError((error, stackTrace) => print("Error updating PoI"));
  }

  /*
  returns a list of all points of interest to show on the map
   */
  Future<List<PointOfInterest>> getAllPointsOfInterest() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await db.getCollection();
    final pointsOfInterest = snapshot.docs.map(
            (doc) {
              return PointOfInterest.fromFireStore(doc);
            }
      ).toList();
    return pointsOfInterest;
  }

  Future<List<PointOfInterest>> getPointOfInterestWhereKeyValue(String keyName, String keyValue) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await db.getDocumentByKey(keyName, keyValue);
    final pointsOfInterest = snapshot.docs.map(
        (doc) => PointOfInterest.fromFireStore(doc)
    ).toList();
    return pointsOfInterest;
  }

  /*
  TODO function that changes rating of a point of interest
   */
  updateRating(PointOfInterest pointOfInterest) {
  }

}