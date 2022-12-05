import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_bird_feeder/database/db.dart';

Future<List<Bird>?> getData(ip) async {
  var response = await http.get(Uri.parse('$ip/getdata'));
  if (response.statusCode == 200) {
    var birdsJson = jsonDecode(response.body) as Map<String, dynamic>;
    List<Bird> birdList = List<Bird>.empty(growable: true);
    for (var birdmap in birdsJson.entries) {
      birdList.add(await Bird.fromJson(int.parse(birdmap.key), birdmap.value));
    }
    return birdList;
  }
  return null;
}
