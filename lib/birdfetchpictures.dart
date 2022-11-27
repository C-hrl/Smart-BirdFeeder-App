
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_bird_feeder/database/db.dart';
import 'package:smart_bird_feeder/theme/theme.dart';
import 'package:smart_bird_feeder/utils.dart';
import 'dart:math';


Map<String, String> headers = {};
bool ok = false;


void updateCookie(http.StreamedResponse response) {
  String? rawCookie = response.headers['set-cookie'];
  if (rawCookie != null) {
    RegExp reg =
        RegExp(r"(_0ad1c|ml-search-session|ml-search-session.sig)\=([^\s]+) ");
    String cookie = "";
    reg.allMatches(rawCookie).forEach((element) {
      cookie += element[0]!;
    });
    headers['cookie'] = cookie;
  }
}

Future<Image?> getBirdImage(Bird bird, Widget defaultWidget) async {
  var response = await http.get(Uri.parse(
      'https://api.ebird.org/v2/ref/taxon/find/?key=cnh95enq2brj&locale=fr-FR&q=${bird.latinName}'));
  if (response.statusCode == 200) {
    List<Map> json = List.from(jsonDecode(response.body));
    if (json.isNotEmpty) {
      String code = json[0]['code'];
      if (!ok) {
        http.Request req = http.Request(
            "Get", Uri.parse('https://search.macaulaylibrary.org/login'))
          ..followRedirects = false;
        http.Client baseClient = http.Client();
        http.StreamedResponse response = await baseClient.send(req);
        updateCookie(response);
        ok = true;
      }

      response = await http.get(
          Uri.parse(
              'https://search.macaulaylibrary.org/api/v2/search?sort=rating_rank_desc&taxonCode=$code'),
          headers: headers);
      if (response.statusCode == 200) {
        json = List.from(jsonDecode(response.body));
        if (json.isNotEmpty) {
          Map birdi = json.firstWhere((map) => map['mediaType'] == 'photo');
          if (birdi.isNotEmpty) {
            int assetId = birdi['assetId'];
            return Image.network(
                'https://cdn.download.ams.birds.cornell.edu/api/v1/asset/$assetId/320',
                headers: headers,
                fit: BoxFit.cover,
                alignment: FractionalOffset.topCenter,
                errorBuilder: (context, error, stackTrace) => defaultWidget,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return defaultWidget;
                  }
                  var size = MediaQuery.of(context).size.width;
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(size * 0.016),
                      child: Stack(alignment: Alignment.center, children: [
                        SizedBox(
                            width: size * 0.16,
                            height: size * 0.16,
                            child: child),
                        BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 4.0,
                            sigmaY: 4.0,
                          ),
                          child: Container(
                            width: size * 0.16,
                            height: size * 0.16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [
                                    0.0,
                                    0.4
                                  ],
                                  colors: [
                                    Colors.white.withOpacity(0.5),
                                    Color.alphaBlend(
                                            randomColor(
                                                    seed: bird.name.hashCode)
                                                .withOpacity(0.18),
                                            colorGolden)
                                        .withOpacity(0.4)
                                  ]), // to adjust blured border
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size * 0.14,
                          height: size * 0.14,
                          child: ClipRRect(
                            child: ColorFilterGenerator.imageFilter(
                                // to adjust image colors
                                saturation: 0.3,
                                brightness: 0.25,
                                hue: 0.1,
                                contrast: 0.4,
                                child: child),
                            borderRadius: BorderRadius.circular(size * 0.014),
                          ),
                        ),
                      ]));
                });
          }
        }
      }
    }
  }
  return null;
}

class ColorFilterGenerator {

    static final identity = <double>[
          1,0,0,0,0,
          0,1,0,0,0,
          0,0,1,0,0,
          0,0,0,1,0,
        ];

    static Widget imageFilter({brightness, saturation, hue, contrast, child}) {
      return ColorFiltered(
        colorFilter: ColorFilter.matrix(
          ColorFilterGenerator.brightnessAdjustMatrix(
            value: brightness,
          )
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(
            ColorFilterGenerator.saturationAdjustMatrix(
              value: saturation,
            )
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(
              ColorFilterGenerator.hueAdjustMatrix(
                value: hue,
              )
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                ColorFilterGenerator.contrastAdjustMatrix(
                  value: contrast,
                )
              ),
              child: child,
            )
          )
        )
      );
    }

    static List<double> hueAdjustMatrix({double value = 0.0}) {
      value = value * pi;

      if (value == 0) {
        return ColorFilterGenerator.identity;
      }

      double cosVal = cos(value);
      double sinVal = sin(value);
      double lumR = 0.213;
      double lumG = 0.715;
      double lumB = 0.072;

      return <double>[
        (lumR + (cosVal * (1 - lumR))) + (sinVal * (-lumR)), (lumG + (cosVal * (-lumG))) + (sinVal * (-lumG)), (lumB + (cosVal * (-lumB))) + (sinVal * (1 - lumB)), 0, 0, (lumR + (cosVal * (-lumR))) + (sinVal * 0.143), (lumG + (cosVal * (1 - lumG))) + (sinVal * 0.14), (lumB + (cosVal * (-lumB))) + (sinVal * (-0.283)), 0, 0, (lumR + (cosVal * (-lumR))) + (sinVal * (-(1 - lumR))), (lumG + (cosVal * (-lumG))) + (sinVal * lumG), (lumB + (cosVal * (1 - lumB))) + (sinVal * lumB), 0, 0, 0, 0, 0, 1, 0,
      ];
    }

    static List<double> brightnessAdjustMatrix({double value = 0.0}) {
      if (value <= 0) {
        value = value * 255;
      } else {
        value = value * 100;
      }

      if (value == 0) {
        return ColorFilterGenerator.identity;
      }

      return <double>[
        1, 0, 0, 0, value, 0, 1, 0, 0, value, 0, 0, 1, 0, value, 0, 0, 0, 1, 0
      ];
    }

    static List<double> contrastAdjustMatrix({double value = 0.0}) {
        double t = (1.0 - (1 + value)) / 2.0 * 255;
        return <double>[
          1 + value,
          0,
          0,
          0,
          t,
          0,
          1 + value,
          0,
          0,
          t,
          0,
          0,
          1 + value,
          0,
          t,
          0,
          0,
          0,
          1,
          0,
        ];
    }

    static List<double> saturationAdjustMatrix({double value = 0.0}) {
      value = value * 100;

      if (value == 0) {
        return ColorFilterGenerator.identity;
      }

      double x = ((1 + ((value > 0) ? ((3 * value) / 100) : (value / 100)))).toDouble();
      double lumR = 0.3086;
      double lumG = 0.6094;
      double lumB = 0.082;

      return <double>[
        (lumR * (1 - x)) + x, lumG * (1 - x), lumB * (1 - x),
        0, 0,
        lumR * (1 - x),
        (lumG * (1 - x)) + x,
        lumB * (1 - x),
        0, 0,
        lumR * (1 - x),
        lumG * (1 - x),
        (lumB * (1 - x)) + x,
        0, 0, 0, 0, 0, 1, 0,
      ];
    }
}