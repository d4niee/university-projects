import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tip of the Day: When hiking always dress in layers. There are 3 base layers: the base layer is your underwear, it will take the sweat off of your skin. The middle layer retains your body heat and keeps you warm. Wool or fleece are great materials for this task. The outer layer protects you from wind and rain. An additional advantage to layering your clothes is, you can take clothes off or on, depending how the weather is. Happy hiking!",
              textAlign: TextAlign.justify,
            ),
          ],
        ),
    );
  }
}