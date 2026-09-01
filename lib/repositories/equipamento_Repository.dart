import 'package:ordem_servico/database/database_service.dart';
import 'package:ordem_servico/models/equipamento.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class EquipamentoRepository {
  EquipamentoRepository(this._databaseService);

  final DatabaseService _databaseService;

  static const String tabela = 'equipamentos';

  Future<int> inserir(Equipamento equipamento) async {
    final database = await _databaseService.database;

    final dados = equipamento.toMap();
    dados.remove('id');

    return database.insert(
      tabela,
      dados,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Equipamento>> listar() async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      orderBy: 'marca ASC, modelo ASC',
    );

    return resultado.map((map) => Equipamento.fromMap(map)).toList();
  }

  Future<List<Equipamento>> listarPorCliente(int clienteId) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'marca ASC, modelo ASC',
    );

    return resultado.map((map) => Equipamento.fromMap(map)).toList();
  }

  Future<Equipamento?> buscarPorId(int id) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Equipamento.fromMap(resultado.first);
  }

  Future<int> atualizar(Equipamento equipamento) async {
    if (equipamento.id == null) {
      throw ArgumentError('Não é possível atualizar um equipamento sem ID.');
    }

    final database = await _databaseService.database;

    final dados = equipamento.toMap();
    dados.remove('id');

    return database.update(
      tabela,
      dados,
      where: 'id = ?',
      whereArgs: [equipamento.id],
    );
  }

  Future<int> excluir(int id) async {
    final database = await _databaseService.database;

    return database.delete('equipamentos', where: 'id = ?', whereArgs: [id]);
  }
}
