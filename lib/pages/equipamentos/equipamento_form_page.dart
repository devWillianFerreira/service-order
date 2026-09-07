import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/cliente_controller.dart';
import 'package:ordem_servico/controllers/equipamento_controller.dart';
import 'package:ordem_servico/models/equipamento.dart';
import 'package:provider/provider.dart';

class EquipamentoFormPage extends StatefulWidget {
  const EquipamentoFormPage({super.key, this.equipamento});

  final Equipamento? equipamento;

  @override
  State<EquipamentoFormPage> createState() => _EquipamentoFormPageState();
}

class _EquipamentoFormPageState extends State<EquipamentoFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tipoController;
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _numeroSerieController;
  late final TextEditingController _observacoesController;

  int? _clienteIdSelecionado;
  bool _salvando = false;
  bool get _editando => widget.equipamento != null;

  @override
  void initState() {
    super.initState();
    final eq = widget.equipamento;
    _clienteIdSelecionado = eq?.clienteId;

    _tipoController = TextEditingController(text: eq?.tipo ?? '');
    _marcaController = TextEditingController(text: eq?.marca ?? '');
    _modeloController = TextEditingController(text: eq?.modelo ?? '');
    _numeroSerieController = TextEditingController(text: eq?.numeroSerie ?? '');
    _observacoesController = TextEditingController(text: eq?.observacoes ?? '');

    // Garante que a lista de clientes esteja disponível para o select
    Future.microtask(() {
      if (mounted) context.read<ClienteController>().carregarClientes();
    });
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _numeroSerieController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final equipamento = Equipamento(
      id: widget.equipamento?.id,
      clienteId: _clienteIdSelecionado!,
      tipo: _tipoController.text.trim(),
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      numeroSerie: _numeroSerieController.text.trim().isEmpty
          ? null
          : _numeroSerieController.text.trim(),
      observacoes: _observacoesController.text.trim().isEmpty
          ? null
          : _observacoesController.text.trim(),
    );

    final controller = context.read<EquipamentoController>();
    final sucesso = await controller.salvarEquipamento(equipamento);

    if (!mounted) return;
    setState(() => _salvando = false);

    if (sucesso) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? 'Erro ao salvar equipamento.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ClienteController>().clientes;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar equipamento' : 'Novo equipamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seleção do Cliente dono do equipamento
              DropdownButtonFormField<int>(
                initialValue: _clienteIdSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Cliente *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                items: clientes.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(c.nome),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _clienteIdSelecionado = val),
                validator: (val) =>
                    val == null ? 'Selecione o cliente responsável' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo (ex: Notebook, Celular) *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o tipo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca *',
                  prefixIcon: Icon(Icons.branding_watermark_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe a marca' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo *',
                  prefixIcon: Icon(Icons.devices_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o modelo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroSerieController,
                decoration: const InputDecoration(
                  labelText: 'Número de Série',
                  prefixIcon: Icon(Icons.qr_code_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  prefixIcon: Icon(Icons.notes_outlined),
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
                        _salvando
                            ? 'Salvando...'
                            : _editando
                            ? 'Salvar alterações'
                            : 'Salvar equipamento',
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
