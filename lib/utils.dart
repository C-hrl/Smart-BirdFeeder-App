import 'dart:math';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:smart_bird_feeder/theme/theme.dart';

Color colorHarmonization(Color inputColor) {
  return inputColor.harmonizeWith(colorHarmonize);
}

Color randomColor({int? seed}) {
  return colorHarmonization(
      Colors.primaries[Random(seed).nextInt(Colors.primaries.length)]);
}