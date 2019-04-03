import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'sliding_page_view.dart';

void main() => runApp(SurfStationsApp());

class SurfStationsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: "SourceSansPro",
      ),
      home: ExamplePage(),
    );
  }
}

class Station {
  final String abbr, name;
  Station({this.abbr, this.name});
}

Future<List<Station>> fetchStationsFromAssets() async {
  Map payload = json.decode(await rootBundle.loadString("station.json"));
  return payload.keys.map((key) { return Station(abbr: key, name: payload[key]["name"]);}).toList();
}

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white);
    return Scaffold( appBar: AppBar(centerTitle: true, title: Text('Bart Stations', style: textStyle, textAlign: TextAlign.center)), body: FutureBuilder<List<Station>>(future: fetchStationsFromAssets(), builder: (context, snapshot) { if (!snapshot.hasData) { return Container(); } return SlidingPageView(children: snapshot.data.map((station) { return Stack(children: <Widget>[Positioned.fill(child: Image.asset("images/${station.abbr}.png", fit: BoxFit.cover)), Positioned(bottom: 100, left: 0, right: 0, child: Container(color: Theme.of(context).primaryColor, child: Column(children: <Widget>[Text(station.name, style: textStyle), Text("#${snapshot.data.indexOf(station)+1}", style: textStyle)])))]); }).toList()); },)  );
  }
}