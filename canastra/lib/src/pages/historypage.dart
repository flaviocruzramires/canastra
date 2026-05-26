import 'dart:async';

import 'package:canastra/src/database/databasehelper.dart';
import 'package:canastra/src/model/partida.dart';
import 'package:canastra/src/pages/gamepage.dart';
import 'package:canastra/src/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Partida>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper().getPartidas();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _future = DatabaseHelper().getPartidas();
    });
  }

  void _novaPartida() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomePage()),
      (route) => false,
    );
  }

  void _deletePartida(Partida partida) {
    unawaited(_deletePartidaAsync(partida));
  }

  Future<void> _deletePartidaAsync(Partida partida) async {
    final id = partida.id;
    if (id == null) return;

    await DatabaseHelper().deletePartida(id);
    await _reload();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partida excluída com sucesso!')),
    );
  }

  void _alterarTipo(Partida partida) {
    unawaited(_alterarTipoAsync(partida));
  }

  Future<void> _alterarTipoAsync(Partida partida) async {
    final id = partida.id;
    if (id == null) return;

    String tempTipo = partida.tipo;

    final novoTipo = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Alterar tipo'),
              content: DropdownButtonFormField<String>(
                value: tempTipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo da partida',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Individual',
                    child: Text('Individual'),
                  ),
                  DropdownMenuItem(
                    value: 'Duplas',
                    child: Text('Duplas'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setStateDialog(() => tempTipo = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempTipo),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || novoTipo == null || novoTipo == partida.tipo) return;

    await DatabaseHelper().updatePartida(
      Partida(
        id: id,
        tipo: novoTipo,
        jogadores: partida.jogadores,
        pontuacao: partida.pontuacao,
      ),
    );
    await _reload();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tipo alterado com sucesso!')),
    );
  }

  void _editarPontuacoes(Partida partida) {
    final id = partida.id;
    if (id == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          tipo: partida.tipo,
          jogadores: partida.jogadores,
          partidaId: id,
          initialPontuacoes: partida.pontuacao,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _reload();
    });
  }

  Widget _buildPartidaItem(Partida partida, int index) {
    final key = partida.id ?? index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Slidable(
        key: ValueKey(key),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (_) => _alterarTipo(partida),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.swap_horiz,
              label: 'Alterar',
            ),
            SlidableAction(
              onPressed: (_) => _editarPontuacoes(partida),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (_) => _deletePartida(partida),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Excluir',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          child: ListTile(
            title: Text(partida.tipo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jogadores: ${partida.jogadores.join(', ')}',
                ),
                const SizedBox(height: 4),
                Text(
                  'Pontuação: ${partida.pontuacao.join(', ')}',
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Partidas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _novaPartida,
                icon: const Icon(Icons.add),
                label: const Text('Nova Partida'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Partida>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Erro ao carregar partidas: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final partidas = snapshot.data;
                if (partidas == null || partidas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma partida registrada.'),
                  );
                }

                return ListView.builder(
                  itemCount: partidas.length,
                  itemBuilder: (context, index) {
                    return _buildPartidaItem(partidas[index], index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
