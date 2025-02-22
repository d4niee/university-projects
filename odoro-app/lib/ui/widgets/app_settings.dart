import 'package:flutter/material.dart';
import 'package:odoro/core/providers/settings_controller.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  static const String title = "App Settings";

  @override
  State<AppSettings> createState() => _AppSettingsState();

}

class _AppSettingsState extends State<AppSettings>{

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            const Card(
              child: ListTile(
                title: Text("Theme"),
              ),
            ),
            Consumer<SettingsController>(
              builder: (context, settings, child) {
              return SwitchListTile(
                  title: const Text("Dark Mode"),
                  subtitle: const Text("Your Odoro experience for night owls"),
                  value: settings.darkMode,
                  onChanged: (newValue) {
                    settings.toggleTheme();
                  },
                );
              }
            ),
            const Card(
              child: ListTile(
                  title: Text("Map")
              ),
            ),

            const ListTile(
              title: Text("Default Zoom"),
            ),
            Consumer<SettingsController>(
                builder: (context, settings, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.defaultZoom,
                          onChanged: (value) {
                            settings.setZoom(value);
                          },
                          // onChangeEnd: (value) {},
                          min: settings.minZoom,
                          max: settings.maxZoom,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Text(settings.defaultZoom.toStringAsFixed(1)),
                      ),

                    ],
                  );
                }
            ),
            const Card(
              child: ListTile(
                title: Text("Other Settings:"),
              ),
            ),
            // testing marker input card

          ],
        ),
      ),
    );
  }
}
