import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/cliente_controller.dart';
import 'package:ordem_servico/controllers/equipamento_controller.dart';
import 'package:ordem_servico/controllers/item_ordem_servico_controller.dart';
import 'package:ordem_servico/controllers/ordem_servico_controller.dart';
import 'controllers/auth_controller.dart';
import 'package:ordem_servico/controllers/tecnico_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'database/database_service.dart';
import 'package:provider/provider.dart';
import 'pages/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await DatabaseService.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ClienteController()),
        ChangeNotifierProvider(create: (_) => TecnicoController()),
        ChangeNotifierProvider(create: (_) => EquipamentoController()),
        ChangeNotifierProvider(create: (_) => ItemOrdemServicoController()),
        ChangeNotifierProvider(create: (_) => OrdemServicoController()),
      ],
      child: const OrdemServicoApp(),
    ),
  );
}

class OrdemServicoApp extends StatelessWidget {
  const OrdemServicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Order',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: {AppRoutes.login: (context) => const AuthGate()},
    );
  }
}
