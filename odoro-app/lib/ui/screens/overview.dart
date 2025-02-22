import 'package:flutter/material.dart';
import '../widgets/location_overview.dart';
import '../widgets/routes_overview.dart';

/*
account management and global settings for the app
 */
class Overview extends StatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {

  // bottomnavbar state
  String title = LocationsList.title;
  int _selectedIndex = 0;

  void onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch(index) {
        case 0:
          title = RoutesList.title;
          break;
        case 1:
          title = LocationsList.title;
          break;
      }
    });
  }

  // widgets in the bottom navbar
  final List<Widget> _pages = [
    const LocationsList(),
    const RoutesList(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
                Icons.person_outline_outlined
            ),
            label: "Locations",
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.app_settings_alt_outlined
            ),
            label: "Routes",
          ),
        ],
        onTap: onNavItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}