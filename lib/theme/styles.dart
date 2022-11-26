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

TextStyle lightText = text.copyWith(color: colorGolden);

TextStyle subtitleText =
    text.copyWith(fontSize: 12, fontWeight: FontWeight.normal);

TextStyle titleText = text.copyWith(fontSize: 16);

TextStyle calendarTitle = TextStyle(color: colorBlue, fontSize: 20);
TextStyle calendarText = TextStyle(color: colorWhite);
