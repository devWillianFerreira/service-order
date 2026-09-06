// TAMANDUÁ-BANDEIRA UM BICHO LEGAL
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

  Future<void> _abrirCadastroCliente() async {
    final cadastrou = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ClienteFormPage()));

    if (cadastrou == true && mounted) {
      context.read<ClienteController>().carregarClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClienteController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastroCliente,
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
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
