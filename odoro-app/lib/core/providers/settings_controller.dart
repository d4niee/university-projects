import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
controls the settings state of the app
handles local settings persistence with shared_preferences

 */
class SettingsController with ChangeNotifier {
  // settings
  bool darkMode = false;
  double defaultZoom = 11.0;
  double minZoom = 5.0;
  double maxZoom = 18.0;

  SettingsController() {
    _loadSettingsFromPrefs();
  }

  // persistence
  SharedPreferences? _preferences;

  _initializePreferences() async {
    // check if null and get instance if true
    _preferences ??= await SharedPreferences.getInstance();
  }

  _loadSettingsFromPrefs() async {
    await _initializePreferences();
    darkMode = _preferences?.getBool("darkMode") ?? false;
    notifyListeners();
  }

  _saveSettingsToPrefs() async {
    await _initializePreferences();
    _preferences?.setBool("darkMode", darkMode);
  }

  void toggleTheme() {
    darkMode = !darkMode;
    _saveSettingsToPrefs();
    notifyListeners();
  }

  void setZoom(double newZoom) {
    defaultZoom = newZoom;
    // savetoprefs
    notifyListeners();
  }

}