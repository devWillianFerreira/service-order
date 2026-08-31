enum PerfilUsuario { administrador, atendente, tecnico }

class Usuario {
  final String id;
  final String nome;
  final String email;
  final PerfilUsuario perfil;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });
}
