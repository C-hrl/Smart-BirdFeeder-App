import 'dart:math';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:smart_bird_feeder/theme/theme.dart';

Color colorHarmonization(Color inputColor) {
  return inputColor.harmonizeWith(colorHarmonize);
}

Color harmonizedRandomColor({required int seed}) {
  //generating random values for RGB
  int red = Random(seed + 50000).nextInt(256);
  int green = Random(seed + 1000).nextInt(256);
  int blue = Random(seed - 1500).nextInt(256);
  //used to make the color "lighter"
  int tintFactor = 2;
  //calculations to make the color more saturated
  int maxValue = [red, green, blue].reduce(max);
  int minValue = [red, green, blue].reduce(min);
  int greyVal = ((red + green + blue) / 3).round();
  int saturationRange = min(255 - greyVal, greyVal);
  int maxColorRange = min(255 - maxValue, minValue);
  int saturationValue = min(saturationRange * 5, maxColorRange);
  if (maxValue == red) {
    red += saturationValue;
  } else if (maxValue == green) {
    green += saturationValue;
  } else {
    blue += saturationValue;
  }

  if (minValue == red) {
    red -= saturationValue;
  } else if (minValue == green) {
    green -= saturationValue;
  } else {
    blue -= saturationValue;
  }

  //genratiog colors
  return colorHarmonization(Color.fromRGBO(red + (255 - red) * tintFactor,
      green + (255 - green) * tintFactor, blue + (255 - blue) * tintFactor, 1));
}
