class ItemOrdemServico {
  final int? id;
  final int ordemServicoId;
  final String descricao;
  final int quantidade;
  final double valorUnitario;

  const ItemOrdemServico({
    this.id,
    required this.ordemServicoId,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
  });

  double get subtotal => quantidade * valorUnitario;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ordem_servico_id': ordemServicoId,
      'descricao': descricao,
      'quantidade': quantidade,
      'valor_unitario': valorUnitario,
    };
  }

  factory ItemOrdemServico.fromMap(Map<String, dynamic> map) {
    return ItemOrdemServico(
      id: map['id'] as int?,
      ordemServicoId: (map['ordem_servico_id'] as num).toInt(),
      descricao: map['descricao'] as String,
      quantidade: (map['quantidade'] as num).toInt(),
      valorUnitario: (map['valor_unitario'] as num).toDouble(),
    );
  }
}
