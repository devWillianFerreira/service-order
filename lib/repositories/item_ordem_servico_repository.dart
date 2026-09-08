import 'package:ordem_servico/database/database_service.dart';
import 'package:ordem_servico/models/item_ordem_servico.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ItemOrdemServicoRepository {
  ItemOrdemServicoRepository(this._databaseService);

  final DatabaseService _databaseService;

  static const String tabela = 'itens_ordem_servico';

  Future<int> inserir(ItemOrdemServico item) async {
    final database = await _databaseService.database;
    final dados = item.toMap()..remove('id');

    return database.insert(
      tabela,
      dados,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<ItemOrdemServico>> listarPorOrdemServico(
    int ordemServicoId,
  ) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'ordem_servico_id = ?',
      whereArgs: [ordemServicoId],
      orderBy: 'id ASC',
    );

    return resultado.map((map) => ItemOrdemServico.fromMap(map)).toList();
  }

  Future<int> atualizar(ItemOrdemServico item) async {
    if (item.id == null) {
      throw ArgumentError('Não é possível atualizar um item sem ID.');
    }

    final database = await _databaseService.database;
    final dados = item.toMap()..remove('id');

    return database.update(
      tabela,
      dados,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> excluir(int id) async {
    final database = await _databaseService.database;
    return database.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}
