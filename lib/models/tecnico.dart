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
    required this.situacao,
  });
}
