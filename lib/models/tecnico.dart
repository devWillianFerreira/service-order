enum SituacaoTecnico { ativo, inativo }

class Tecnico {
  final int? id;
  final String nome;
  final String contato;
  final String especialidade;
  final SituacaoTecnico situacao;

  const Tecnico({
    this.id,
    required this.nome,
    required this.contato,
    required this.especialidade,
    this.situacao = SituacaoTecnico.ativo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'contato': contato,
      'especialidade': especialidade,
      'situacao': situacao.name,
    };
  }

  factory Tecnico.fromMap(Map<String, dynamic> map) {
    return Tecnico(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      contato: map['contato'] as String,
      especialidade: map['especialidade'] as String,
      situacao: SituacaoTecnico.values.byName(map['situacao'] as String),
    );
  }
  Tecnico copyWith({
    int? id,
    String? nome,
    String? contato,
    String? especialidade,
    SituacaoTecnico? situacao,
  }) {
    return Tecnico(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      contato: contato ?? this.contato,
      especialidade: especialidade ?? this.especialidade,
      situacao: situacao ?? this.situacao,
    );
  }
}
