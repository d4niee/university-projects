// define colors used by the app as static const in here:

import 'package:flutter/material.dart';

class CustomColors {
  //static const MaterialColor myPrimarySwatch = MaterialColor(primary, swatch)
  // static const Color myPrimaryColor = Color.something;
  static const Color myPrimarySwatch = Color.fromRGBO(1, 90, 107, 1.0);
  static const MaterialColor customPrimarySwatch = MaterialColor(
      0xFF015A6B,
      {
        50: Color.fromRGBO(1, 90, 107, .1),
        100: Color.fromRGBO(1, 90, 107, .2),
        200: Color.fromRGBO(1, 90, 107, .3),
        300: Color.fromRGBO(1, 90, 107, .4),
        400: Color.fromRGBO(1, 90, 107, .5),
        500: Color.fromRGBO(1, 90, 107, .6),
        600: Color.fromRGBO(1, 90, 107, .7),
        700: Color.fromRGBO(1, 90, 107, .8),
        800: Color.fromRGBO(1, 90, 107, .9),
        900: Color.fromRGBO(1, 90, 107, 1),
      });

  // mapping template for color to materialcolor:
  /*
  const Map<int, Color> colorCodes = {
    50: Color.fromRGBO(136,14,79, .1),
    100: Color.fromRGBO(136,14,79, .2),
    200: Color.fromRGBO(136,14,79, .3),
    300: Color.fromRGBO(136,14,79, .4),
    400: Color.fromRGBO(136,14,79, .5),
    500: Color.fromRGBO(136,14,79, .6),
    600: Color.fromRGBO(136,14,79, .7),
    700: Color.fromRGBO(136,14,79, .8),
    800: Color.fromRGBO(136,14,79, .9),
    900: Color.fromRGBO(136,14,79, 1),
  };
  MaterialColor customMaterialColor = MaterialColor(0xFF<hexvalueofcolor>, colorCodes);
   */
}