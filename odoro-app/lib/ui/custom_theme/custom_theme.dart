import 'package:flutter/material.dart';

/*
app styling for light and dark mode
 */
class CustomTheme {
  static get lightTheme => ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
          seedColor: MyColorTheme.primary,
          primary: MyColorTheme.primary,
          secondary: MyColorTheme.secondary,
          // card
          surface:MyColorTheme.primaryGreyShade,
          //
          background: MyColorTheme.white,

      )
  );
  static get darkTheme => ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color.fromRGBO(65, 175, 151, 1.0),


    )
  );

}

class MyColorTheme {
  static const primary = Color.fromRGBO(65, 175, 151, 1);
  static const secondary = Color.fromRGBO(0, 114, 92, 1);
  static const primaryLightShade = Color.fromRGBO(141, 207, 193, 1.0);
  static const primaryGreyShade = Color.fromRGBO(196, 229, 219, 1);
  static const primaryDarkestShade = Color.fromRGBO(20, 32, 28, 1);
  static const atomicTangerine = Color.fromRGBO(255, 153, 102, 1);
  static const darkBLueGray = Color.fromRGBO(102, 102, 153, 1);
  static const mud = Color.fromRGBO(112, 84, 62, 1);
  static const blue = Color.fromRGBO(31, 117, 254, 1);
  static const mutedBlue = Color.fromRGBO(117, 164, 239, 1.0);
  static const offBlack = Color.fromRGBO(16, 12, 8, 1.0);
  static const randomOffWhite = Color.fromRGBO(240, 234, 214, 1.0);
  static const white = Color.fromRGBO(255, 255, 255, 1.0);
}