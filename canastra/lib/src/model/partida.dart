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

  static Partida fromMap(Map<String, dynamic> map) {
    return Partida(
      id: map['id'],
      tipo: map['tipo'],
      jogadores: map['jogadores'].split(','), // Converter de string para lista
      pontuacao: map['pontuacao']
          .split(',')
          .map(int.parse)
          .toList(), // Converter de string para lista de inteiros
    );
  }
}
