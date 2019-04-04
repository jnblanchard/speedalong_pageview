import 'package:flutter/material.dart';
import 'sliding_page_view.dart';
import 'stations.dart';

void main() => runApp(StationApp());

class StationApp extends StatelessWidget {
  get _textStyle => TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white);
  @override Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: "SourceSansPro",
      ),
      home: Scaffold( appBar: AppBar(centerTitle: true, title: Text('Bart Stations', style: _textStyle, textAlign: TextAlign.center)), body: FutureBuilder<List<Station>>(future: fetchStations(), builder: (context, snapshot) { if (!snapshot.hasData) { return Container(); } return SlidingPageView(children: snapshot.data.map((station) { return Stack(children: <Widget>[Positioned.fill(child: Image.asset("images/${station.abbr}.png", fit: BoxFit.cover)), Positioned(bottom: 100, left: 0, right: 0, child: Container(color: Theme.of(context).primaryColor, child: Column(children: <Widget>[Text(station.name, style: _textStyle), Text("#${snapshot.data.indexOf(station)+1}", style: _textStyle)])))]); }).toList()); },)  ),
    );
  }
}