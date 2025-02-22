import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/firebase_api.dart';

class FakedataService {
  late final FirebaseApi db;
  Random rnd = new Random();

  FakedataService() {
    db = FirebaseApi(collectionPath: FirebaseApi.fakedata);
  }

  Future<String> getFakedata() async {
    var randomDoc = rnd.nextInt(3).toString();
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await db.getDocumentById(randomDoc);

    return "";
  }
}
