import 'package:flutter/material.dart';
import 'package:odoro/core/services/pointofinterest_service.dart';
import 'package:odoro/models/pointofinterest_model.dart';
import 'package:odoro/ui/widgets/location_list_card.dart';
import '../widgets/route_list_card.dart';

/*
shows all saved routes of a user
analog zu flutter übung
 */
class PoIList extends StatefulWidget {
  const PoIList({Key? key}) : super(key: key);

  @override
  State<PoIList> createState() => _PoIListState();
}

class _PoIListState extends State<PoIList> {
/*
  Future<List<RouteCard>> getRouteList() async {
    List<RouteCard> routes = [];
    routes.add(RouteCard());
    return routes;
  }

 */

  PointOfInterestService pointOfInterestService = PointOfInterestService();
  late List<PointOfInterest> pointsOfService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overview"),
      ),
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
    );
  }
}