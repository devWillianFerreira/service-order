import 'package:ordem_servico/database/database_service.dart';
import 'package:ordem_servico/models/ordem_servico.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OrdemServicoRepository {
  OrdemServicoRepository(this._databaseService);

  final DatabaseService _databaseService;

  static const String tabela = 'ordens_servico';

  Future<int> inserir(OrdemServico ordemServico) async {
    final database = await _databaseService.database;

    final dados = ordemServico.toMap();
    dados.remove('id');

    return database.insert(
      tabela,
      dados,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<OrdemServico>> listar() async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      orderBy: 'data_abertura DESC',
    );

    return resultado.map((map) => OrdemServico.fromMap(map)).toList();
  }

  Future<OrdemServico?> buscarPorId(int id) async {
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

    return OrdemServico.fromMap(resultado.first);
  }

  Future<OrdemServico?> buscarPorNumero(String numero) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'numero = ?',
      whereArgs: [numero],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return OrdemServico.fromMap(resultado.first);
  }

  Future<List<OrdemServico>> listarPorStatus(StatusOrdemServico status) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'data_abertura DESC',
    );

    return resultado.map((map) => OrdemServico.fromMap(map)).toList();
  }

  Future<List<OrdemServico>> listarPorCliente(int clienteId) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'data_abertura DESC',
    );

    return resultado.map((map) => OrdemServico.fromMap(map)).toList();
  }

  Future<List<OrdemServico>> listarPorEquipamento(int equipamentoId) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'equipamento_id = ?',
      whereArgs: [equipamentoId],
      orderBy: 'data_abertura DESC',
    );

    return resultado.map((map) => OrdemServico.fromMap(map)).toList();
  }

  Future<List<OrdemServico>> listarPorPrioridade(Prioridade prioridade) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'prioridade = ?',
      whereArgs: [prioridade.name],
      orderBy: 'data_abertura DESC',
    );

    return resultado.map((map) => OrdemServico.fromMap(map)).toList();
  }

  Future<List<OrdemServico>> listarPorTecnico(int tecnicoId) async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'tecnico_id = ?',
      whereArgs: [tecnicoId],
      orderBy: 'data_abertura DESC',
    );

    return resultado.map((map) => OrdemServico.fromMap(map)).toList();
  }

  Future<List<OrdemServico>> listarAbertas() async {
    final database = await _databaseService.database;

    final resultado = await database.query(
      tabela,
      where: 'status NOT IN (?, ?)',
      whereArgs: [
        StatusOrdemServico.concluida.name,
        StatusOrdemServico.cancelada.name,
      ],
      orderBy: 'data_limite ASC',
    );

    return resultado.map((map) => OrdemServico.fromMap(map)).toList();
  }

  Future<int> atualizar(OrdemServico ordemServico) async {
    if (ordemServico.id == null) {
      throw ArgumentError(
        'Não é possível atualizar uma ordem de serviço sem ID.',
      );
    }

    final database = await _databaseService.database;

    final dados = ordemServico.toMap();
    dados.remove('id');

    return database.update(
      tabela,
      dados,
      where: 'id = ?',
      whereArgs: [ordemServico.id],
    );
  }

  Future<int> excluir(int id) async {
    final database = await _databaseService.database;

    return database.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}
