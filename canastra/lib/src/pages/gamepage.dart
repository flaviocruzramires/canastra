import 'package:canastra/src/database/databasehelper.dart';
import 'package:canastra/src/model/partida.dart';
import 'package:flutter/material.dart';

class _PlayerScoreData {
  bool bateu = false;
  bool pegouMorto = false;

  int canastraLimpa = 0; // * 500
  int canastraSuja = 0; // * 100
  int canastraAteA = 0; // * 1000
  int qtdA = 0; // * 20
  int qtdCorringuinha = 0; // * 10
  int qtdCorringao = 0; // * 50
  int qtdTresVermelho = 0; // * 100
  int qtdCartas = 0; // * 10

  int qtdCartasNaMao = 0; // negativo: * 10

  int get positivos {
    var total = 0;
    if (bateu) total += 100;
    if (pegouMorto) total += 100;
    total += canastraLimpa * 500;
    total += canastraSuja * 100;
    total += canastraAteA * 1000;
    total += qtdA * 20;
    total += qtdCorringuinha * 10;
    total += qtdCorringao * 50;
    total += qtdTresVermelho * 100;
    total += qtdCartas * 10;
    return total;
  }

  int get negativos {
    var total = 0;
    if (!pegouMorto) total += 100; // "Se não pegou morto"
    total += qtdCartasNaMao * 10;
    return total;
  }

  int get total => positivos - negativos;
}

class _IntCounter extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int step;
  final int? multiplierPoints;
  final void Function(int) onChanged;

  const _IntCounter({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.step = 1,
    this.multiplierPoints,
  });

  @override
  Widget build(BuildContext context) {
    final pointsText = multiplierPoints == null
        ? null
        : '${value * multiplierPoints!} pts';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              pointsText == null ? label : '$label ($pointsText)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: 'Diminuir',
            onPressed: value <= min ? null : () => onChanged(value - step),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 42,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Aumentar',
            onPressed: () => onChanged(value + step),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final String tipo;
  final List<String> jogadores;

  final int? partidaId;
  final List<int>? initialPontuacoes;

  GamePage({
    required this.tipo,
    required this.jogadores,
    this.partidaId,
    this.initialPontuacoes,
  });

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final List<_PlayerScoreData> _scores;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // A tela é desenhada em 2 colunas (Jogador/Dupla 1 e 2).
    // Mesmo se por algum motivo vier menos nomes, garantimos 2 estados.
    final count = widget.jogadores.length >= 2 ? widget.jogadores.length : 2;
    _scores = List.generate(count, (_) => _PlayerScoreData());
  }

  Future<void> savePartida() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final pontuacoes = _scores.take(2).map((s) => s.total).toList();

      final partida = Partida(
        id: widget.partidaId,
        tipo: widget.tipo,
        jogadores: widget.jogadores,
        pontuacao: pontuacoes,
      );

      if (widget.partidaId != null) {
        await DatabaseHelper().updatePartida(partida);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partida alterada com sucesso!')),
        );
      } else {
        await DatabaseHelper().insertPartida(partida);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partida salva com sucesso!')),
        );
      }

      if (!mounted) return;

      await Navigator.pushNamedAndRemoveUntil(
        context,
        '/history',
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar partida: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildPlayerColumn({
    required int index,
    required String name,
  }) {
    final s = _scores[index];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Pontos positivos',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Divider(),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Bateu (+100)'),
              value: s.bateu,
              onChanged: (v) => setState(() => s.bateu = v ?? false),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Pegou morto (+100)'),
              value: s.pegouMorto,
              onChanged: (v) => setState(() => s.pegouMorto = v ?? false),
            ),
            _IntCounter(
              label: 'Canastra limpa (x500)',
              value: s.canastraLimpa,
              multiplierPoints: 500,
              onChanged: (v) => setState(() => s.canastraLimpa = v),
            ),
            _IntCounter(
              label: 'Canastra suja (x100)',
              value: s.canastraSuja,
              multiplierPoints: 100,
              onChanged: (v) => setState(() => s.canastraSuja = v),
            ),
            _IntCounter(
              label: 'Canastra de A até A (x1000)',
              value: s.canastraAteA,
              multiplierPoints: 1000,
              onChanged: (v) => setState(() => s.canastraAteA = v),
            ),
            _IntCounter(
              label: 'Quantidade de A (x20)',
              value: s.qtdA,
              multiplierPoints: 20,
              onChanged: (v) => setState(() => s.qtdA = v),
            ),
            _IntCounter(
              label: 'Corringuinha (x10)',
              value: s.qtdCorringuinha,
              multiplierPoints: 10,
              onChanged: (v) => setState(() => s.qtdCorringuinha = v),
            ),
            _IntCounter(
              label: 'Corringão (x50)',
              value: s.qtdCorringao,
              multiplierPoints: 50,
              onChanged: (v) => setState(() => s.qtdCorringao = v),
            ),
            _IntCounter(
              label: '3 vermelho (x100)',
              value: s.qtdTresVermelho,
              multiplierPoints: 100,
              onChanged: (v) => setState(() => s.qtdTresVermelho = v),
            ),
            _IntCounter(
              label: 'Quantidade de cartas (x10)',
              value: s.qtdCartas,
              multiplierPoints: 10,
              onChanged: (v) => setState(() => s.qtdCartas = v),
            ),
            const SizedBox(height: 10),
            Text(
              'Pontos negativos',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Divider(),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Se não pegou morto (-100)'),
              trailing: Text(
                s.pegouMorto ? '0' : '100',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            _IntCounter(
              label: 'Cartas na mão (x10)',
              value: s.qtdCartasNaMao,
              multiplierPoints: 10,
              onChanged: (v) => setState(() => s.qtdCartasNaMao = v),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text(
                    '${s.total}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.partidaId != null
              ? 'Editar partida ${widget.tipo}'
              : 'Partida ${widget.tipo}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPlayerColumn(
                      index: 0,
                      name: widget.jogadores.isNotEmpty ? widget.jogadores[0] : 'Jogador 1',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPlayerColumn(
                      index: 1,
                      name: widget.jogadores.length > 1 ? widget.jogadores[1] : 'Jogador 2',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : savePartida,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.partidaId != null
                            ? 'Salvar alterações'
                            : 'Salvar Partida',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
