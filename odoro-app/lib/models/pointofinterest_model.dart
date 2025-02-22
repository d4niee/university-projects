import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odoro/models/data_model.dart';

/*
entity that represents a location/ point of interest on the map
 */
class PointOfInterest implements DataModel {
  final String pointOfInterestName;
  final String pointOfInterestDescription;
  int? rating;
  final double latitude;
  final double longitude;
  final String markerId;
  final String userName;

  PointOfInterest({
    required this.pointOfInterestName,
    required this.pointOfInterestDescription,
    this.rating,
    required this.latitude,
    required this.longitude,
    required this.markerId,
    required this.userName,
  });

  /*
   constructor to create point of interest from firebase snapshot
   */
  factory PointOfInterest.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot
  ) {
    final data = snapshot.data();
    return PointOfInterest(
        pointOfInterestName: data?["pointOfInterestName"],
        pointOfInterestDescription: data?["pointOfInterestDescription"],
        rating: data?["rating"],
        latitude: data?["pointOfInterestLatitude"],
        longitude: data?["pointOfInterestLongitude"],
        markerId: data?["markerId"],
        userName: data?["userName"]);
  }

  /*
  maps point of interest to json
   */
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "pointOfInterestName": pointOfInterestName,
      "pointOfInterestDescription": pointOfInterestDescription,
      "pointOfInterestRating": rating,
      "pointOfInterestLatitude": latitude,
      "pointOfInterestLongitude": longitude,
      "markerId": markerId,
      "userName": userName,
    };
  }

}