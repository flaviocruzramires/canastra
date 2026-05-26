import 'package:flutter/material.dart';

class RulesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Regras do Jogo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'As regras do jogo de Canastra são...\n\n'
          '1. O jogo é jogado com dois baralhos de 52 cartas.\n'
          '2. Cada jogador ou dupla deve tentar formar canastras...\n'
          '3. As pontuações são registradas ao final de cada partida.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
