import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/ordem_servico_controller.dart';
import 'package:ordem_servico/widgets/dashboard/dashboard_indicator_card.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _valorTotalServicos = 0;
  bool _carregandoValor = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_carregarDashboard);
  }

  Future<void> _carregarDashboard() async {
    final controller = context.read<OrdemServicoController>();
    await controller.carregarOrdensServico();
    final total = await controller.calcularValorTotalServicos();

    if (!mounted) return;
    setState(() {
      _valorTotalServicos = total;
      _carregandoValor = false;
    });
  }

  String _formatarMoeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdemServicoController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDashboard,
          ),
        ],
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(OrdemServicoController controller) {
    if (controller.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.errorMessage!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _carregarDashboard,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 650
            ? 2
            : 1;

        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: colunas,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            DashboardIndicatorCard(
              titulo: 'Total de OS',
              valor: controller.quantidadeOrdens.toString(),
              icone: Icons.assignment_outlined,
            ),

            DashboardIndicatorCard(
              titulo: 'OS abertas',
              valor: controller.quantidadeAbertas.toString(),
              icone: Icons.folder_open_outlined,
            ),

            DashboardIndicatorCard(
              titulo: 'Em atendimento',
              valor: controller.quantidadeEmAtendimento.toString(),
              icone: Icons.build_outlined,
            ),

            DashboardIndicatorCard(
              titulo: 'Concluídas',
              valor: controller.quantidadeConcluidas.toString(),
              icone: Icons.check_circle_outline,
            ),

            DashboardIndicatorCard(
              titulo: 'Urgentes',
              valor: controller.quantidadeUrgentes.toString(),
              icone: Icons.priority_high_outlined,
            ),

            DashboardIndicatorCard(
              titulo: 'Atrasadas',
              valor: controller.quantidadeAtrasadas.toString(),
              icone: Icons.warning_amber_outlined,
            ),

            DashboardIndicatorCard(
              titulo: 'Valor total dos serviços',
              valor: _carregandoValor
                  ? 'Calculando...'
                  : _formatarMoeda(_valorTotalServicos),
              icone: Icons.attach_money_outlined,
              descricao: 'Mão de obra e itens registrados',
            ),
          ],
        );
      },
    );
  }
}
