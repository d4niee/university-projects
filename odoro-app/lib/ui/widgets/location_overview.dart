/*
shows all saved routes of a user
analog zu flutter übung
 */
import 'package:flutter/material.dart';
import 'package:odoro/ui/widgets/route_list_card.dart';

import '../../core/services/pointofinterest_service.dart';
import '../../models/pointofinterest_model.dart';
import 'location_list_card.dart';

class LocationsList extends StatefulWidget {
  const LocationsList({Key? key}) : super(key: key);

  static const title = "Browse Locations";

  @override
  State<LocationsList> createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList> {


  PointOfInterestService pointOfInterestService = PointOfInterestService();
  late List<PointOfInterest> pointsOfService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: FutureBuilder<List<PointOfInterest>>(
          future: pointOfInterestService.getAllPointsOfInterest(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final location = snapshot.data![index];
                  return LocationListCard(pointOfInterest: location);
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search_outlined),
        onPressed: () {},
      ),
    );
  }
}