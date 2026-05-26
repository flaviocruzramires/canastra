import 'dart:io' show Platform;

import 'package:canastra/src/database/databasehelper.dart';
import 'package:canastra/src/pages/historypage.dart';
import 'package:canastra/src/pages/homepage.dart';
import 'package:canastra/src/pages/rulespage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseHelper().database;

  runApp(const CanastraApp());
}

class CanastraApp extends StatelessWidget {
  const CanastraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/history': (BuildContext context) => const HistoryPage(),
        '/rules': (BuildContext context) => RulesPage(),
      },
    );
  }
}
