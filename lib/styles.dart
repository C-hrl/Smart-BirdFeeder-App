import 'package:flutter/material.dart';
import 'package:smart_bird_feeder/theme.dart';

//-----SIDEBAR STYLES-----//

const BoxDecoration sideBarColor = BoxDecoration(color: colorGolden);

final BoxDecoration sideBarSelectedItemBoxDecoration = BoxDecoration(
  color: colorGoldenAccent,
  borderRadius: BorderRadius.circular(5),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 30,
    )
  ],
);

const IconThemeData selectedIconTheme = IconThemeData(
  color: colorWhite,
  size: 30,
);

const IconThemeData iconTheme = IconThemeData(
  color: colorGoldenAccent,
  size: 30,
);

//-----TEXT STYLES-----//

const TextStyle text =
    TextStyle(color: colorGoldenAccent, fontWeight: FontWeight.w700);

const TextStyle selectedText =
    TextStyle(color: colorWhite, fontWeight: FontWeight.w700);
