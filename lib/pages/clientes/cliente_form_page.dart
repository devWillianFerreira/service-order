import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/cliente_controller.dart';
import 'package:ordem_servico/models/cliente.dart';
import 'package:provider/provider.dart';

class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nome;
  late final TextEditingController _documento;
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  late final TextEditingController _endereco;

  bool _salvando = false;
  bool get _editando => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nome = TextEditingController(text: c?.nome ?? '');
    _documento = TextEditingController(text: c?.documento ?? '');
    _telefone = TextEditingController(text: c?.telefone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _endereco = TextEditingController(text: c?.endereco ?? '');
  }

  @override
  void dispose() {
    _nome.dispose();
    _documento.dispose();
    _telefone.dispose();
    _email.dispose();
    _endereco.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final clienteAtualizado = Cliente(
      id: widget.cliente?.id,
      nome: _nome.text.trim(),
      documento: _documento.text.trim(),
      telefone: _telefone.text.trim(),
      email: _email.text.trim(),
      endereco: _endereco.text.trim(),
    );

    final controller = context.read<ClienteController>();
    final sucesso = await controller.salvarCliente(clienteAtualizado);

    if (!mounted) return;
    setState(() => _salvando = false);

    if (sucesso) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Erro ao salvar cliente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Novo cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documento,
                decoration: const InputDecoration(
                  labelText: 'CPF / CNPJ *',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o documento'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone *',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v != null &&
                      v.trim().isNotEmpty &&
                      (!v.contains('@') || !v.contains('.'))) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endereco,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _salvando
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.save),
                      label: Text(
                        _editando ? 'Salvar alterações' : 'Salvar cliente',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
