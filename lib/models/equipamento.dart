class Equipamento {
  final int? id;
  final int clienteId;
  final String tipo;
  final String marca;
  final String modelo;
  final String? numeroSerie;
  final String? observacoes;

  const Equipamento({
    this.id,
    required this.clienteId,
    required this.tipo,
    required this.marca,
    required this.modelo,
    this.numeroSerie,
    this.observacoes,
  });
}
