import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Bird {
  String name;
  String latinName;
  int temperature;
  String soundPath;
  DateTime date;

  Bird(this.name, this.latinName, this.temperature, this.soundPath, this.date);

  @override
  String toString() =>
      "Bird( name:$name; latinName:$latinName; temperature:$temperature; soundPath:$soundPath; date:$date)"; // Just for print()
}

Box<List<Bird>>? cachedDb;

Future<Box<List<Bird>>> setupDatabase() async {
  Hive.init('./BirdsHive/');
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BirdAdapter());
  }
  var box = await Hive.openBox<List<Bird>>('birdsBox');
  if (kDebugMode) {
    // fill box for testing
    var now = DateTime.now();
    box.clear();
    addToKey(box, now, Bird('name 1', 'latin 1', 20, "path/sound.ogg", now));
    addToKey(box, now, Bird('name 2', 'latin 2', 20, "path/sound.ogg", now));
    var other = now.add(const Duration(days: 3, hours: 9));
    addToKey(
        box, other, Bird('name 3', 'latin 3', 20, "path/sound.ogg", other));

    var other2 = now.add(const Duration(days: 3, hours: 10));
    addToKey(
        box, other2, Bird('name 4', 'latin 4', 20, "path/sound.ogg", other2));
  }
  return box;
}

Future<Box<List<Bird>>> getDatabase() async {
  return cachedDb == null ? await setupDatabase() : cachedDb!;
}

Future<List<Bird>> getBirds(DateTime date) async {
  return (await getDatabase())
      .get(storeDate(date), defaultValue: List.empty())!;
}

void main() async {
  // Register Adapter
  Hive.registerAdapter(BirdAdapter());

  var box = await Hive.openBox<List<Bird>>('birdsBox');

  var now = DateTime.now();

  addToKey(box, now, Bird('name 1', 'latin 1', 20, "path/sound.ogg", now));
  addToKey(box, now, Bird('name 2', 'latin 2', 20, "path/sound.ogg", now));
  var other = now.add(const Duration(days: 3, hours: 9));
  addToKey(box, other, Bird('name 3', 'latin 3', 20, "path/sound.ogg", other));

  var other2 = now.add(const Duration(days: 3, hours: 10));
  addToKey(
      box, other2, Bird('name 4', 'latin 4', 20, "path/sound.ogg", other2));

  debugPrint(box.toMap().entries.toString());
}

int storeDate(DateTime date) {
  return (DateUtils.dateOnly(date).millisecondsSinceEpoch / 86400000).round();
}

void addToKey(Box<List<Bird>> box, DateTime date, Bird bird) {
  int dateInt = storeDate(date);
  if (box.containsKey(dateInt)) {
    box.get(dateInt)?.add(bird);
  } else {
    box.put(dateInt, List<Bird>.filled(1, bird, growable: true));
  }
}

// Can be generated automatically
class BirdAdapter extends TypeAdapter<Bird> {
  @override
  final typeId = 0;

  @override
  Bird read(BinaryReader reader) {
    return Bird(reader.readString(), reader.readString(), reader.readInt(),
        reader.readString(), DateTime.parse(reader.readString()));
  }

  @override
  void write(BinaryWriter writer, Bird obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.latinName);
    writer.writeInt(obj.temperature);
    writer.writeString(obj.soundPath);
    writer.writeString(obj.date.toString());
  }
}
