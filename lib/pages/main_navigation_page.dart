import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/auth_controller.dart';
import 'package:ordem_servico/pages/clientes/clientes_page.dart';
import 'package:ordem_servico/pages/dashboard/dashboard_page.dart';
import 'package:ordem_servico/pages/equipamentos/equipamentos_page.dart';
import 'package:ordem_servico/pages/ordens_servico/ordens_servico_page.dart';
import 'package:ordem_servico/pages/tecnicos/tecnicos_page.dart';
import 'package:provider/provider.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _telas = const [
    DashboardPage(),
    OrdensServicoPage(),
    ClientesPage(),
    TecnicosPage(),
    EquipamentosPage(),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _telas.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: false,

        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_circle, size: 28, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'OS Manutenção',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthController>().sair();
            },
          ),
          const SizedBox(width: 8),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool telaPequena = constraints.maxWidth < 700;

              return SizedBox(
                width: double.infinity,
                height: 58,
                child: TabBar(
                  controller: _tabController,

                  // Em telas pequenas permite rolagem horizontal.
                  // Em telas maiores distribui melhor os itens.
                  isScrollable: telaPequena,
                  tabAlignment: telaPequena
                      ? TabAlignment.start
                      : TabAlignment.fill,

                  indicatorSize: TabBarIndicatorSize.tab,

                  labelPadding: EdgeInsets.symmetric(
                    horizontal: telaPequena ? 16 : 8,
                  ),

                  tabs: const [
                    Tab(
                      icon: Icon(Icons.dashboard_outlined),
                      text: 'Dashboard',
                    ),
                    Tab(icon: Icon(Icons.assignment_outlined), text: 'Ordens'),
                    Tab(icon: Icon(Icons.people_outline), text: 'Clientes'),
                    Tab(
                      icon: Icon(Icons.engineering_outlined),
                      text: 'Técnicos',
                    ),
                    Tab(
                      icon: Icon(Icons.precision_manufacturing_outlined),
                      text: 'Equipamentos',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      body: TabBarView(controller: _tabController, children: _telas),
    );
  }
}
