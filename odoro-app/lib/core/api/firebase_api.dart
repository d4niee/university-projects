import 'package:cloud_firestore/cloud_firestore.dart';
/*
implements basic crud operations for firebase
https://stackoverflow.com/questions/53517382/query-a-single-document-from-firestore-in-flutter-cloud-firestore-plugin
 */
class FirebaseApi {

  // collection paths
  static const String users = "users";
  static const String pointsOfInterest = "poi";
  static const String markers = "markers";
  static const String routes = "routes";
  static const String fakedata = "fakedata";

  final db = FirebaseFirestore.instance;
  final String collectionPath;

  FirebaseApi({required this.collectionPath});

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection() {
    return db.collection(collectionPath).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection() {
    return db.collection(collectionPath).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocumentById(String id) {
    return db.collection(collectionPath).doc(id).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocumentByKey(String keyName, keyValue) {
    return db.collection(collectionPath)
        .where(keyName, isEqualTo: keyValue)
        .get();
  }

  Future<void> removeDocument(String id){
    return db.collection(collectionPath).doc(id).delete();
  }

  Future<DocumentReference<Map<String, dynamic>>> addDocument(Map<String, dynamic> data) {
    // add autogenerates an id, with set() have to pass one
    return db.collection(collectionPath).add(data);
  }

  Future<void> setDocument(Map<String, dynamic> data, String id) {
    // add autogenerates an id, with set() have to pass one
    return db.collection(collectionPath).doc(id).set(data);
  }

  Future<void> updateDocument(Map<String, dynamic> data , String id) {
    return db.collection(collectionPath).doc(id).update(data);
  }

}