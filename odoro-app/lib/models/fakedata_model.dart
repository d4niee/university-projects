import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odoro/models/data_model.dart';

class Fakedata implements DataModel{
  final String fakePicture;
  final String fakeText;

  Fakedata({required this.fakePicture, required this.fakeText});
/*
  factory MapFakedata.fromFireStore(){
    return Fakedata(
      fakePicture: ,
      fakeText:
    );
  }
*/
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}