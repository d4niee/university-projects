import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DBTest extends StatefulWidget {

  @override
  _DBTest createState() => _DBTest();
}

class _DBTest extends State<DBTest> {

  final db = FirebaseFirestore.instance;

  void addData() async {

    final user = <String, dynamic>{
      "first": "Ada",
      "last": "Lovelace",
      "born": 1816
    };
    // Add a new document with a generated ID
    db.collection("users").add(user).then((DocumentReference doc) =>
    print('DocumentSnapshot added with ID: ${doc.id}'));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DBTEST')
      ),
      body: Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addData();
        },
      ),
    );
  }

}