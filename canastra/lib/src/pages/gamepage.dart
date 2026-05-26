import 'package:canastra/src/database/databasehelper.dart';
import 'package:canastra/src/model/partida.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final String tipo;
  final List<String> jogadores;

  GamePage({required this.tipo, required this.jogadores});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Map<String, TextEditingController> scoreControllers = {};

  @override
  void initState() {
    super.initState();
    for (var jogador in widget.jogadores) {
      scoreControllers[jogador] = TextEditingController();
    }
  }

  void savePartida() async {
    List<int> pontuacoes = scoreControllers.values.map((controller) {
      return int.tryParse(controller.text) ?? 0; // Default to 0 if invalid
    }).toList();

    Partida partida = Partida(
      tipo: widget.tipo,
      jogadores: widget.jogadores,
      pontuacao: pontuacoes,
    );

    await DatabaseHelper().insertPartida(partida);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Partida salva com sucesso!')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Partida \${widget.tipo}')),
      body: Column(
        children: [
          for (var jogador in widget.jogadores)
            ListTile(
              title: Text(jogador),
              trailing: SizedBox(
                width: 100,
                child: TextField(
                  controller: scoreControllers[jogador],
                  decoration: InputDecoration(labelText: 'Pontuação'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ElevatedButton(onPressed: savePartida, child: Text('Salvar Partida')),
        ],
      ),
    );
  }
}
