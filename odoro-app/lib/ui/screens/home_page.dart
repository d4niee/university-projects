// https://www.fluttercampus.com/guide/77/how-to-set-notched-floating-action-button-in-bottom-navigation-bar/
// https://stackoverflow.com/questions/59455684/how-to-make-bottomnavigationbar-notch-transparent
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/core/services/weather_service.dart';
import 'package:odoro/ui/custom_theme/custom_theme.dart';
import 'package:odoro/ui/screens/sign_in_page.dart';
import 'package:odoro/ui/widgets/welcome_card.dart';
import 'package:provider/provider.dart';
import '../../core/routes/route_generator.dart';
import 'package:odoro/ui/widgets/forecast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WeatherService weather = WeatherService();
  late LatLng currentLocation;

  @override
  void initState() {
    super.initState();
  }

  bool userIsLoggedIn() {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    currentLocation = Provider.of<LatLng>(context);

    /// If the User is not logged in go to the login page
    if (!userIsLoggedIn()) {
      return SignInPage();
    }
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, RouteGenerator.appSettingsPage);
              })
        ],
      ),
      // show weather at current location
      body: Column(children: const [
        Image(
            image: NetworkImage(
                "https://www.hotel-bergheimat.de/wcms/Clients/102201452031120/Images/Resized_21322202012011619_1920x600.JPG")),
        WelcomeCard(),
        Divider(
          color: MyColorTheme.atomicTangerine,
          thickness: 0.8,
          indent: 15,
          endIndent: 15,
        ),
        ListTile(
          title: Text("Weather Forecast",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
              )),
        ),
        Expanded(child: Forecast()),
      ]),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteGenerator.mapPage);
        },
        tooltip: 'Start Exploring!',
        child: const Icon(Icons.map_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: MyColorTheme.primary,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.wb_sunny_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                weather.getForecast(currentLocation.latitude.toString(),
                    currentLocation.longitude.toString());
              },
              tooltip: "Refresh Weather",
            ),
            const Padding(
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                //TODO : implement search for route/ place by name/author
                onPressed: null,
                tooltip: "Search a Point of Interest",
              ),
              padding: EdgeInsets.only(right: 50),
            ),
            Padding(
              child: IconButton(
                icon: const Icon(
                  Icons.collections_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, RouteGenerator.userRoutesPage);
                },
                tooltip: "Browse Points of Interest",
              ),
              padding: const EdgeInsets.only(left: 50),
            ),
            IconButton(
              icon: const Icon(
                Icons.star_border_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, RouteGenerator.favouritesPage);
              },
              tooltip: "Browse Your Favourites",
            ),
          ],
        ),
      ),
    );
  }
}
