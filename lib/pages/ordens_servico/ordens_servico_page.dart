import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/cliente_controller.dart';
import 'package:ordem_servico/controllers/equipamento_controller.dart';
import 'package:ordem_servico/controllers/ordem_servico_controller.dart';
import 'package:ordem_servico/controllers/tecnico_controller.dart';
import 'package:ordem_servico/models/ordem_servico.dart';
import 'package:provider/provider.dart';

import 'ordem_servico_detalhes_page.dart';
import 'ordem_servico_form_page.dart';

class OrdensServicoPage extends StatefulWidget {
  const OrdensServicoPage({super.key});

  @override
  State<OrdensServicoPage> createState() => _OrdensServicoPageState();
}

class _OrdensServicoPageState extends State<OrdensServicoPage> {
  final _searchController = TextEditingController();

  StatusOrdemServico? _filtroStatus;
  Prioridade? _filtroPrioridade;
  int? _filtroTecnicoId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<OrdemServicoController>().carregarOrdensServico();
      context.read<ClienteController>().carregarClientes();
      context.read<EquipamentoController>().carregarEquipamentos();
      context.read<TecnicoController>().carregarTecnicos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario([OrdemServico? os]) async {
    final atualizou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => OrdemServicoFormPage(ordemServico: os)),
    );
    if (atualizou == true && mounted) {
      context.read<OrdemServicoController>().carregarOrdensServico();
    }
  }

  Future<void> _confirmarExclusao(OrdemServico os) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir OS'),
        content: Text('Deseja excluir a OS #${os.numero}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;
    await context.read<OrdemServicoController>().excluirOrdemServico(os.id!);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdemServicoController>();
    final clientes = context.watch<ClienteController>().clientes;
    final equipamentos = context.watch<EquipamentoController>().equipamentos;
    final tecnicos = context.watch<TecnicoController>().tecnicos;

    final mapClientes = {for (final c in clientes) c.id: c.nome};
    final mapEquipamentos = {
      for (final e in equipamentos) e.id: '${e.tipo} ${e.modelo}',
    };
    final mapTecnicos = {for (final t in tecnicos) t.id: t.nome};

    final buscaTexto = _searchController.text.trim().toLowerCase();

    final listaFiltrada = controller.ordensServico.where((os) {
      if (_filtroStatus != null && os.status != _filtroStatus) return false;
      if (_filtroPrioridade != null && os.prioridade != _filtroPrioridade) {
        return false;
      }

      if (_filtroTecnicoId != null && os.tecnicoId != _filtroTecnicoId) {
        return false;
      }

      if (buscaTexto.isNotEmpty) {
        final numOs = os.numero.toLowerCase();
        final nomeCliente = (mapClientes[os.clienteId] ?? '').toLowerCase();
        final descEquip = (mapEquipamentos[os.equipamentoId] ?? '')
            .toLowerCase();
        final nomeTecnico = (mapTecnicos[os.tecnicoId] ?? '').toLowerCase();

        final bateu =
            numOs.contains(buscaTexto) ||
            nomeCliente.contains(buscaTexto) ||
            descEquip.contains(buscaTexto) ||
            nomeTecnico.contains(buscaTexto);

        if (!bateu) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ordens de Serviço')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Buscar por número, cliente, equipamento ou técnico...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<StatusOrdemServico?>(
                  value: _filtroStatus,
                  hint: const Text('Status: Todos'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Status: Todos'),
                    ),
                    ...StatusOrdemServico.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _filtroStatus = val),
                ),
                const SizedBox(width: 12),
                DropdownButton<Prioridade?>(
                  value: _filtroPrioridade,
                  hint: const Text('Prioridade: Todas'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Prioridade: Todas'),
                    ),
                    ...Prioridade.values.map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _filtroPrioridade = val),
                ),
                const SizedBox(width: 12),
                DropdownButton<int?>(
                  value: _filtroTecnicoId,
                  hint: const Text('Técnico: Todos'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Técnico: Todos'),
                    ),
                    ...tecnicos.map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.nome)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _filtroTecnicoId = val),
                ),
              ],
            ),
          ),
          const Divider(height: 8),

          Expanded(
            child: controller.carregando
                ? const Center(child: CircularProgressIndicator())
                : listaFiltrada.isEmpty
                ? const Center(child: Text('Nenhuma OS encontrada.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: listaFiltrada.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final os = listaFiltrada[index];
                      final cor = switch (os.status) {
                        StatusOrdemServico.concluida => Colors.green,
                        StatusOrdemServico.cancelada => Colors.red,
                        StatusOrdemServico.emAtendimento => Colors.orange,
                        _ => Colors.blue,
                      };

                      final nomeCliente =
                          mapClientes[os.clienteId] ?? 'Cliente #';
                      final nomeTecnico =
                          mapTecnicos[os.tecnicoId] ?? 'Não atribuído';

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cor,
                            radius: 8,
                          ),
                          title: Text(
                            'OS #${os.numero} • ${os.status.name.toUpperCase()}',
                          ),
                          subtitle: Text(
                            'Cliente: $nomeCliente\nTécnico: $nomeTecnico • Prioridade: ${os.prioridade.name.toUpperCase()}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmarExclusao(os),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrdemServicoDetalhesPage(
                                  ordemServicoId: os.id!,
                                ),
                              ),
                            );
                            if (context.mounted) {
                              controller.carregarOrdensServico();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
