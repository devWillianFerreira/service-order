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
}
