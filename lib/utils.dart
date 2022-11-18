import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:smart_bird_feeder/theme.dart';

Color harmonizer(Color inputColor) {
  return inputColor.harmonizeWith(colorHarmonize);
}
