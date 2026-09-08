import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordem_servico/controllers/cliente_controller.dart';
import 'package:ordem_servico/models/cliente.dart';
import 'cliente_form_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ClienteController>().carregarClientes();
    });
  }

  Future<void> _abrirFormularioCliente([Cliente? cliente]) async {
    final atualizou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: cliente)),
    );

    if (atualizou == true && mounted) {
      context.read<ClienteController>().carregarClientes();
    }
  }

  Future<void> _confirmarExclusao(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text('Deseja realmente excluir ${cliente.nome}?'),
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

    final controller = context.read<ClienteController>();
    // Certifique-se de que o método no seu controller recebe o id ou o cliente
    final sucesso = await controller.excluirCliente(cliente.id!);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente excluído com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Erro ao excluir cliente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClienteController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioCliente(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Novo cliente'),
      ),
      body: _buildContent(controller),
    );
  }

  Widget _buildContent(ClienteController controller) {
    if (controller.isLoading) {
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
              onPressed: controller.carregarClientes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (controller.clientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum cliente cadastrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre um cliente para começar a registrar ordens.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.clientes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildClienteCard(controller.clientes[index]);
      },
    );
  }

  Widget _buildClienteCard(Cliente cliente) {
    final letraInicial = cliente.nome.isNotEmpty
        ? cliente.nome[0].toUpperCase()
        : '?';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Text(letraInicial)),
        title: Text(
          cliente.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Doc: ${cliente.documento} • Tel: ${cliente.telefone}'),
              if (cliente.email.isNotEmpty)
                Text(
                  cliente.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Excluir',
          onPressed: () => _confirmarExclusao(cliente),
        ),
        onTap: () => _abrirFormularioCliente(cliente),
      ),
    );
  }
}
