import 'package:flutter/material.dart';
import 'package:smart_bird_feeder/theme/theme.dart';

//-----SIDEBAR STYLES-----//

BoxDecoration sideBarColor = BoxDecoration(color: colorGolden);

final BoxDecoration sideBarSelectedItemBoxDecoration = BoxDecoration(
  color: colorGoldenAccent,
  borderRadius: BorderRadius.circular(5),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 2,
    )
  ],
);

IconThemeData selectedIconTheme = IconThemeData(
  color: colorWhite,
  size: 30,
);

IconThemeData iconTheme = IconThemeData(
  color: colorGoldenAccent,
  size: 30,
);

//-----TEXT STYLES-----//

TextStyle text =
    TextStyle(color: colorGoldenAccent, fontWeight: FontWeight.w700);

TextStyle accentText =
    TextStyle(color: colorWhite, fontWeight: FontWeight.w700);

TextStyle calendarTitle = TextStyle(color: colorBlue, fontSize: 20);
TextStyle calendarText = TextStyle(color: colorWhite);
