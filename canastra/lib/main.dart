import 'package:canastra/src/pages/historypage.dart';
import 'package:canastra/src/pages/homepage.dart';
import 'package:canastra/src/pages/rulespage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/history': (BuildContext context) => HistoryPage(),
        '/rules': (BuildContext context) => RulesPage(),
      },
    ),
  );
}
