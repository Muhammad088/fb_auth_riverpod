import 'package:flutter/material.dart';

void coloredPrint({required String msg, required Color color}) {
  String colorCode = "21";
  switch (color) {
    case Colors.black:
      colorCode = "30";
      break;
    case Colors.red:
      colorCode = "31";
      break;
    case Colors.green:
      colorCode = "32";
      break;
    case Colors.yellow:
      colorCode = "33";
      break;
    case Colors.blue:
      colorCode = "34";
      break;
    case Colors.cyan:
      colorCode = "36";
      break;
    case Colors.white:
      colorCode = "37";
      break;
    default:
      colorCode = "37";
      break;
  }

  print("\x1B[${colorCode}m$msg\x1B[0m");
}
