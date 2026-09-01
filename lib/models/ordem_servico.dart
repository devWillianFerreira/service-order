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
    this.status = StatusOrdemServico.aberta,
    required this.dataAbertura,
    required this.dataLimite,
    this.diagnostico = '',
    this.solucao = '',
    this.valorMaoDeObra = 0.0,
  });

  bool get ordemAtrasada {
    return status != StatusOrdemServico.concluida &&
        status != StatusOrdemServico.cancelada &&
        dataLimite.isBefore(DateTime.now());
  }

  bool get ordemUrgente => prioridade == Prioridade.urgente;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'cliente_id': clienteId,
      'equipamento_id': equipamentoId,
      'tecnico_id': tecnicoId,
      'descricao_problema': descricaoProblema,
      'prioridade': prioridade.name,
      'status': status.name,
      'data_abertura': dataAbertura.toIso8601String(),
      'data_limite': dataLimite.toIso8601String(),
      'diagnostico': diagnostico,
      'solucao': solucao,
      'valor_mao_de_obra': valorMaoDeObra,
    };
  }

  factory OrdemServico.fromMap(Map<String, dynamic> map) {
    return OrdemServico(
      id: map['id'] as int?,
      numero: map['numero'] as String,
      clienteId: (map['cliente_id'] as num).toInt(),
      equipamentoId: (map['equipamento_id'] as num).toInt(),
      tecnicoId: map['tecnico_id'] != null
          ? (map['tecnico_id'] as num).toInt()
          : null,
      descricaoProblema: map['descricao_problema'] as String,
      prioridade: Prioridade.values.byName(map['prioridade'] as String),
      status: StatusOrdemServico.values.byName(map['status'] as String),
      dataAbertura: DateTime.parse(map['data_abertura'] as String),
      dataLimite: DateTime.parse(map['data_limite'] as String),
      diagnostico: map['diagnostico'] as String? ?? '',
      solucao: map['solucao'] as String? ?? '',
      valorMaoDeObra: (map['valor_mao_de_obra'] as num?)?.toDouble() ?? 0.0,
    );
  }

  OrdemServico copyWith({
    int? id,
    String? numero,
    int? clienteId,
    int? equipamentoId,
    int? tecnicoId,
    String? descricaoProblema,
    Prioridade? prioridade,
    StatusOrdemServico? status,
    DateTime? dataAbertura,
    DateTime? dataLimite,
    String? diagnostico,
    String? solucao,
    double? valorMaoDeObra,
  }) {
    return OrdemServico(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clienteId: clienteId ?? this.clienteId,
      equipamentoId: equipamentoId ?? this.equipamentoId,
      tecnicoId: tecnicoId ?? this.tecnicoId,
      descricaoProblema: descricaoProblema ?? this.descricaoProblema,
      prioridade: prioridade ?? this.prioridade,
      status: status ?? this.status,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dataLimite: dataLimite ?? this.dataLimite,
      diagnostico: diagnostico ?? this.diagnostico,
      solucao: solucao ?? this.solucao,
      valorMaoDeObra: valorMaoDeObra ?? this.valorMaoDeObra,
    );
  }
}
