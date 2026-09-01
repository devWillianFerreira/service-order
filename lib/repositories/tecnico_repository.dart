import 'package:ordem_servico/database/database_service.dart';
import 'package:ordem_servico/models/tecnico.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TecnicoRepository {
  TecnicoRepository(this._databaseService);

  final DatabaseService _databaseService;

  static const String tabela = 'tecnicos';

  Future<int> inserir(Tecnico tecnico) async {
    final database = await _databaseService.database;

    final dados = tecnico.toMap();
    dados.remove('id');

    return database.insert(
      tabela,
      dados,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Tecnico>> listar({String busca = ''}) async {
    final database = await _databaseService.database;

    List<Map<String, dynamic>> resultado;

    if (busca.trim().isEmpty) {
      resultado = await database.query(tabela, orderBy: 'nome ASC');
    } else {
      final termo = '%${busca.trim()}%';
      resultado = await database.query(
        tabela,
        where: 'nome LIKE ? OR especialidade LIKE ? OR contato LIKE ?',
        whereArgs: [termo, termo, termo],
        orderBy: 'nome ASC',
      );
    }

    return resultado.map((map) => Tecnico.fromMap(map)).toList();
  }

  Future<List<Tecnico>> listarAtivos() async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'situacao = ?',
      whereArgs: [SituacaoTecnico.ativo.name],
      orderBy: 'nome ASC',
    );

    return resultado.map((map) => Tecnico.fromMap(map)).toList();
  }

  Future<Tecnico?> buscarPorId(int id) async {
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

    return Tecnico.fromMap(resultado.first);
  }

  Future<int> atualizar(Tecnico tecnico) async {
    if (tecnico.id == null) {
      throw ArgumentError('Não é possível atualizar um técnico sem ID.');
    }

    final database = await _databaseService.database;

    final dados = tecnico.toMap();

    dados.remove('id');

    return database.update(
      tabela,
      dados,
      where: 'id = ?',
      whereArgs: [tecnico.id],
    );
  }

  Future<int> excluir(int id) async {
    final database = await _databaseService.database;

    return database.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}
