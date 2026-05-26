import 'package:canastra/src/pages/gamepage.dart';
import 'package:canastra/src/pages/rulespage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  bool isDuo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Pontuação - Canastra')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<bool>(
              value: isDuo,
              items: [
                DropdownMenuItem(value: false, child: Text('Individual')),
                DropdownMenuItem(value: true, child: Text('Duplas')),
              ],
              onChanged: (value) {
                setState(() {
                  isDuo = value!;
                });
              },
            ),
            TextField(
              controller: player1Controller,
              decoration: InputDecoration(labelText: 'Nome do Jogador 1'),
            ),
            TextField(
              controller: player2Controller,
              decoration: InputDecoration(labelText: 'Nome do Jogador 2'),
            ),

            if (isDuo)
              TextField(
                controller: player1Controller,
                decoration: InputDecoration(labelText: 'Nome da Dupla 1'),
              ),
            TextField(
              controller: player2Controller,
              decoration: InputDecoration(labelText: 'Nome da Dupla 2'),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Regras'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RulesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
