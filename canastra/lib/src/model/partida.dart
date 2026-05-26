class Partida {
  final int? id;
  final String tipo; // "Individual" ou "Duplas"
  final List<String> jogadores;
  final List<int> pontuacao; // Lista de pontuações dos jogadores

  Partida({
    this.id,
    required this.tipo,
    required this.jogadores,
    required this.pontuacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'jogadores': jogadores.join(','), // Armazenar como string
      'pontuacao': pontuacao.join(','), // Armazenar como string
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'tipo': tipo,
      'jogadores': jogadores.join(','), // Armazenar como string
      'pontuacao': pontuacao.join(','), // Armazenar como string
    };
  }

  static List<String> _parseJogadores(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    final text = value?.toString() ?? '';
    if (text.isEmpty) return [];
    return text.split(',').map((e) => e.trim()).toList();
  }

  static List<int> _parsePontuacao(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e is int ? e : int.parse(e.toString().trim()))
          .toList();
    }
    final text = value?.toString() ?? '';
    if (text.isEmpty) return [];
    return text
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList();
  }

  static Partida fromMap(Map<String, dynamic> map) {
    return Partida(
      id: map['id'] as int?,
      tipo: map['tipo'] as String,
      jogadores: _parseJogadores(map['jogadores']),
      pontuacao: _parsePontuacao(map['pontuacao']),
    );
  }
}
