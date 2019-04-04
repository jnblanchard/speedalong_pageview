import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class Station {
  final String abbr, name;
  Station({this.abbr, this.name});
}

Future<List<Station>> fetchStations() async {
  Map payload = json.decode(await rootBundle.loadString("station.json"));
  return payload.keys.map((key) { return Station(abbr: key, name: payload[key]["name"]);}).toList();
}