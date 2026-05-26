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

  void _startGame() {
    final name1 = player1Controller.text.trim();
    final name2 = player2Controller.text.trim();

    if (name1.isEmpty || name2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os dois nomes para iniciar.')),
      );
      return;
    }

    final tipo = isDuo ? 'Duplas' : 'Individual';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          tipo: tipo,
          jogadores: [name1, name2],
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.pushNamed(context, '/history');
  }

  @override
  void dispose() {
    player1Controller.dispose();
    player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label1 = isDuo ? 'Nome da Dupla 1' : 'Nome do Jogador 1';
    final label2 = isDuo ? 'Nome da Dupla 2' : 'Nome do Jogador 2';

    return Scaffold(
      appBar: AppBar(title: Text('Registro de Pontuação - Canastra')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<bool>(
              value: isDuo,
              items: [
                DropdownMenuItem(value: false, child: Text('Individual')),
                DropdownMenuItem(value: true, child: Text('Duplas')),
              ],
              decoration: const InputDecoration(
                labelText: 'Modo',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  isDuo = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: player1Controller,
              decoration: InputDecoration(labelText: label1),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: player2Controller,
              decoration: InputDecoration(labelText: label2),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _startGame(),
            ),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                child: const Text('Iniciar Partida'),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico de Partidas'),
              onTap: _openHistory,
            ),
            ListTile(
              leading: const Icon(Icons.rule),
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
