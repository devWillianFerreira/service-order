import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ordem_servico/controllers/cliente_controller.dart';
import 'package:ordem_servico/controllers/equipamento_controller.dart';
import 'package:ordem_servico/controllers/ordem_servico_controller.dart';
import 'package:ordem_servico/controllers/tecnico_controller.dart';
import 'package:ordem_servico/models/ordem_servico.dart';
import 'package:ordem_servico/models/tecnico.dart';
import 'package:provider/provider.dart';

class OrdemServicoFormPage extends StatefulWidget {
  const OrdemServicoFormPage({super.key, this.ordemServico});

  final OrdemServico? ordemServico;

  @override
  State<OrdemServicoFormPage> createState() => _OrdemServicoFormPageState();
}

class _OrdemServicoFormPageState extends State<OrdemServicoFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _numero;
  late final TextEditingController _descricao;
  late final TextEditingController _maoDeObra;
  late final TextEditingController _diagnostico;
  late final TextEditingController _solucao;

  int? _clienteId;
  int? _equipamentoId;
  int? _tecnicoId;
  late StatusOrdemServico _status;
  late Prioridade _prioridade;
  late DateTime _dataLimite;
  String? _fotoPath;
  bool _salvando = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final os = widget.ordemServico;
    _numero = TextEditingController(text: os?.numero ?? '');
    _descricao = TextEditingController(text: os?.descricaoProblema ?? '');
    _maoDeObra = TextEditingController(
      text: os?.valorMaoDeObra.toString() ?? '0.0',
    );
    _diagnostico = TextEditingController(text: os?.diagnostico ?? '');
    _solucao = TextEditingController(text: os?.solucao ?? '');

    _clienteId = os?.clienteId;
    _equipamentoId = os?.equipamentoId;
    _tecnicoId = os?.tecnicoId;
    _status = os?.status ?? StatusOrdemServico.aberta;
    _prioridade = os?.prioridade ?? Prioridade.baixa;
    _dataLimite = os?.dataLimite ?? DateTime.now().add(const Duration(days: 7));
    _fotoPath = os?.fotoPath;

    Future.microtask(() {
      if (!mounted) return;
      context.read<ClienteController>().carregarClientes();
      context.read<EquipamentoController>().carregarEquipamentos();
      context.read<TecnicoController>().carregarTecnicos();
    });
  }

  @override
  void dispose() {
    _numero.dispose();
    _descricao.dispose();
    _maoDeObra.dispose();
    _diagnostico.dispose();
    _solucao.dispose();
    super.dispose();
  }

  Future<void> _selecionarOrigemImagem() async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (origem == null) return;

    final XFile? foto = await _picker.pickImage(
      source: origem,
      imageQuality: 80,
    );
    if (foto != null) {
      setState(() => _fotoPath = foto.path);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final diag = _diagnostico.text.trim();
    final sol = _solucao.text.trim();

    if (_status == StatusOrdemServico.concluida &&
        diag.isEmpty &&
        sol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para concluir a OS, registre ao menos o diagnóstico ou a solução.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final os = OrdemServico(
      id: widget.ordemServico?.id,
      numero: _numero.text.trim(),
      clienteId: _clienteId!,
      equipamentoId: _equipamentoId!,
      tecnicoId: _tecnicoId,
      descricaoProblema: _descricao.text.trim(),
      valorMaoDeObra:
          double.tryParse(_maoDeObra.text.replaceAll(',', '.')) ?? 0.0,
      status: _status,
      prioridade: _prioridade,
      dataAbertura: widget.ordemServico?.dataAbertura ?? DateTime.now(),
      dataLimite: _dataLimite,
      diagnostico: diag,
      solucao: sol,
      fotoPath: _fotoPath,
    );

    final controller = context.read<OrdemServicoController>();
    final ok = await controller.salvarOrdemServico(os);

    if (!mounted) return;
    setState(() => _salvando = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Erro ao salvar OS.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ClienteController>().clientes;
    final equipamentos = context.watch<EquipamentoController>().equipamentos;
    final todosTecnicos = context.watch<TecnicoController>().tecnicos;

    final tecnicos = todosTecnicos.where((t) {
      return t.situacao == SituacaoTecnico.ativo || t.id == _tecnicoId;
    }).toList();

    final equipamentosFiltrados = equipamentos
        .where((e) => e.clienteId == _clienteId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ordemServico != null ? 'Editar OS' : 'Nova OS'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _numero,
              decoration: const InputDecoration(labelText: 'Número da OS *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _clienteId,
              decoration: const InputDecoration(labelText: 'Cliente *'),
              items: clientes
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.nome)),
                  )
                  .toList(),
              onChanged: (val) => setState(() {
                _clienteId = val;
                _equipamentoId = null;
              }),
              validator: (v) => v == null ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _equipamentoId,
              decoration: const InputDecoration(labelText: 'Equipamento *'),
              items: equipamentosFiltrados
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text('${e.tipo} - ${e.modelo}'),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _equipamentoId = val),
              validator: (v) => v == null ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _tecnicoId,
              decoration: const InputDecoration(labelText: 'Técnico'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Nenhum')),
                ...tecnicos.map((t) {
                  final isInativo = t.situacao != SituacaoTecnico.ativo;
                  return DropdownMenuItem(
                    value: t.id,
                    child: Text('${t.nome}${isInativo ? ' (Inativo)' : ''}'),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _tecnicoId = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Prioridade>(
              initialValue: _prioridade,
              decoration: const InputDecoration(labelText: 'Prioridade'),
              items: Prioridade.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _prioridade = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StatusOrdemServico>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: StatusOrdemServico.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data Limite *'),
              subtitle: Text(
                '${_dataLimite.day.toString().padLeft(2, '0')}/${_dataLimite.month.toString().padLeft(2, '0')}/${_dataLimite.year}',
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dataLimite,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (d != null) setState(() => _dataLimite = d);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricao,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descrição do Problema *',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _diagnostico,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Diagnóstico Técnico',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _solucao,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Solução Aplicada'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maoDeObra,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Mão de Obra (R\$)'),
            ),
            const SizedBox(height: 16),

            if (_fotoPath != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 320,
                    maxHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_fotoPath!), fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _selecionarOrigemImagem,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Trocar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _fotoPath = null),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Remover',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ] else
              OutlinedButton.icon(
                onPressed: _selecionarOrigemImagem,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Adicionar Foto / Evidência'),
              ),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Salvando...' : 'Salvar OS'),
            ),
          ],
        ),
      ),
    );
  }
}
