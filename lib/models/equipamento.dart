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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'observacoes': observacoes,
    };
  }

  factory Equipamento.fromMap(Map<String, dynamic> map) {
    return Equipamento(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      tipo: map['tipo'] as String,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      numeroSerie: map['numero_serie'] as String?,
      observacoes: map['observacoes'] as String?,
    );
  }
}
