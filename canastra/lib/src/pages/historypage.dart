import 'package:canastra/src/database/databasehelper.dart';
import 'package:canastra/src/model/partida.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Histórico de Partidas')),
      body: FutureBuilder<List<Partida>>(
        future: DatabaseHelper().getPartidas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma partida registrada.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final partida = snapshot.data![index];
              return ListTile(
                title: Text(partida.tipo),
                subtitle: Text(
                  'Jogadores: ${partida.jogadores.join(', ')}\nPontuação: ${partida.pontuacao.join(', ')}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
