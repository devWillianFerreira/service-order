import 'package:ordem_servico/database/database_service.dart';
import 'package:ordem_servico/models/cliente.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ClienteRepository {
  ClienteRepository(this._databaseService);

  final DatabaseService _databaseService;

  static const String tabela = 'clientes';

  Future<int> inserir(Cliente cliente) async {
    final database = await _databaseService.database;

    final dados = cliente.toMap();
    dados.remove('id');

    return database.insert(
      tabela,
      dados,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Cliente>> listar() async {
    final database = await _databaseService.database;

    final resultado = await database.query(tabela, orderBy: 'nome ASC');

    return resultado.map((map) => Cliente.fromMap(map)).toList();
  }

  Future<Cliente?> buscarPorId(int id) async {
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

    return Cliente.fromMap(resultado.first);
  }

  Future<int> atualizar(Cliente cliente) async {
    if (cliente.id == null) {
      throw ArgumentError('Não é possível atualizar um cliente sem ID.');
    }

    final database = await _databaseService.database;

    final dados = cliente.toMap();

    return database.update(
      tabela,
      dados,
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> excluir(int id) async {
    final database = await _databaseService.database;

    return database.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}
