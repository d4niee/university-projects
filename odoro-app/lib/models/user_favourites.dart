import 'package:cloud_firestore/cloud_firestore.dart';

class UserFavourites {
  final String title;
  final double latitude;
  final double longitude;
  final String desc;

  UserFavourites(
      {required this.title,
      required this.latitude,
      required this.longitude,
      required this.desc});

  factory UserFavourites.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserFavourites(
        title: data?["poi_title"],
        latitude: data?["poi_lat"],
        longitude: data?["poi_lon"],
        desc: data?["poi_desc"]);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "poi_title": title,
      "poi_lat": latitude,
      "poi_lon": longitude,
      "poi_desc": desc
    };
  }
}
