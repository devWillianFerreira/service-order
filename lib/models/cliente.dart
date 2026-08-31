class Cliente {
  final int? id;
  final String nome;
  final String documento;
  final String telefone;
  final String email;
  final String endereco;

  const Cliente({
    this.id,
    required this.nome,
    required this.documento,
    required this.telefone,
    required this.email,
    required this.endereco,
  });
}
