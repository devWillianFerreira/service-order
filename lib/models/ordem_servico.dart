enum Prioridade { baixa, media, alta, urgente }

enum StatusOrdemServico { aberta, emAtendimento, concluida, cancelada }

class OrdemServico {
  final int? id;
  final String numero;
  final int clienteId;
  final int equipamentoId;
  final int? tecnicoId;

  final String descricaoProblema;

  final Prioridade prioridade;
  final StatusOrdemServico status;

  final DateTime dataAbertura;
  final DateTime dataLimite;

  final String diagnostico;
  final String solucao;

  final double valorMaoDeObra;

  const OrdemServico({
    this.id,
    required this.numero,
    required this.clienteId,
    required this.equipamentoId,
    this.tecnicoId,
    required this.descricaoProblema,
    required this.prioridade,
    required this.status,
    required this.dataAbertura,
    required this.dataLimite,
    required this.diagnostico,
    required this.solucao,
    required this.valorMaoDeObra,
  });
}
