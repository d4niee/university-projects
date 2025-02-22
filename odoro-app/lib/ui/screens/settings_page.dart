import 'package:flutter/material.dart';
import '../widgets/app_settings.dart';
import '../widgets/account_settings.dart';

/*
account management and global settings for the app
 */
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  // bottomnavbar state
  String title = AccountSettings.title;
  int _selectedIndex = 0;

  void onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch(index) {
        case 0:
          title = AccountSettings.title;
          break;
        case 1:
          title = AppSettings.title;
          break;
      }
    });
  }

  // widgets in the bottom navbar
  final List<Widget> _pages = [
    const AccountSettings(),
    const AppSettings(),
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
              label: "Account",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.app_settings_alt_outlined
              ),
              label: "App Settings",
          ),
        ],
        onTap: onNavItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}