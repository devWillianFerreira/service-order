import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/equipamento_controller.dart';
import 'package:ordem_servico/models/equipamento.dart';
import 'package:provider/provider.dart';

import 'equipamento_form_page.dart';

class EquipamentosPage extends StatefulWidget {
  const EquipamentosPage({super.key});

  @override
  State<EquipamentosPage> createState() => _EquipamentosPageState();
}

class _EquipamentosPageState extends State<EquipamentosPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<EquipamentoController>().carregarEquipamentos();
    });
  }

  Future<void> _abrirFormulario([Equipamento? equipamento]) async {
    final atualizou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipamentoFormPage(equipamento: equipamento),
      ),
    );

    if (atualizou == true && mounted) {
      context.read<EquipamentoController>().carregarEquipamentos();
    }
  }

  Future<void> _confirmarExclusao(Equipamento equipamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir equipamento'),
        content: Text(
          'Deseja excluir "${equipamento.tipo} - ${equipamento.modelo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final controller = context.read<EquipamentoController>();
    final sucesso = await controller.excluirEquipamento(equipamento.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Equipamento excluído com sucesso!'
              : controller.errorMessage ?? 'Erro ao excluir equipamento.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EquipamentoController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo equipamento'),
      ),
      body: _buildContent(controller),
    );
  }

  Widget _buildContent(EquipamentoController controller) {
    if (controller.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.carregarEquipamentos,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (controller.equipamentos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.devices_other_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum equipamento cadastrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.equipamentos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final equipamento = controller.equipamentos[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.build_outlined)),
            title: Text('${equipamento.tipo} - ${equipamento.marca}'),
            subtitle: Text(
              'Modelo: ${equipamento.modelo}${equipamento.numeroSerie != null && equipamento.numeroSerie!.isNotEmpty ? ' • S/N: ${equipamento.numeroSerie}' : ''}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmarExclusao(equipamento),
            ),
            onTap: () => _abrirFormulario(equipamento),
          ),
        );
      },
    );
  }
}
