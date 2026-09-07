import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/tecnico_controller.dart';
import 'package:ordem_servico/models/tecnico.dart';
import 'package:ordem_servico/pages/tecnicos/tecnico_form_page.dart';
import 'package:provider/provider.dart';

class TecnicosPage extends StatefulWidget {
  const TecnicosPage({super.key});

  @override
  State<TecnicosPage> createState() => _TecnicosPageState();
}

class _TecnicosPageState extends State<TecnicosPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<TecnicoController>().carregarTecnicos();
    });
  }

  Future<void> _abrirFormularioTecnico([Tecnico? tecnico]) async {
    final atualizou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TecnicoFormPage(tecnico: tecnico)),
    );

    if (atualizou == true && mounted) {
      context.read<TecnicoController>().carregarTecnicos();
    }
  }

  Future<void> _confirmarExclusao(Tecnico tecnico) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir técnico'),
        content: Text('Deseja realmente excluir ${tecnico.nome}?'),
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

    final controller = context.read<TecnicoController>();
    final sucesso = await controller.excluirTecnico(tecnico.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Técnico excluído com sucesso!'
              : controller.errorMessage ?? 'Erro ao excluir técnico.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TecnicoController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioTecnico(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Novo técnico'),
      ),
      body: _buildContent(controller),
    );
  }

  Widget _buildContent(TecnicoController controller) {
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
              onPressed: controller.carregarTecnicos,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (controller.tecnicos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.engineering_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum técnico cadastrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre um técnico para atribuí-lo às ordens.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.tecnicos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildTecnicoCard(controller.tecnicos[index]);
      },
    );
  }

  Widget _buildTecnicoCard(Tecnico tecnico) {
    final cor = switch (tecnico.situacao) {
      SituacaoTecnico.ativo => Colors.green,
      _ => Colors.red, // Qualquer outro estado fica vermelho
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          radius: 8, // Bolinha indicadora colorida
        ),
        title: Text(tecnico.nome),
        subtitle: Text(
          '${tecnico.situacao.name.toUpperCase()} • ${tecnico.contato}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmarExclusao(tecnico),
        ),
        onTap: () => _abrirFormularioTecnico(tecnico),
      ),
    );
  }
}
