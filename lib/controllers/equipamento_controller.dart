import 'package:flutter/foundation.dart';
import 'package:ordem_servico/database/database_service.dart';
import '../models/equipamento.dart';
import '../repositories/equipamento_repository.dart';

class EquipamentoController extends ChangeNotifier {
  EquipamentoController({EquipamentoRepository? equipamentoRepository})
    : _repository =
          equipamentoRepository ??
          EquipamentoRepository(DatabaseService.instance);

  final EquipamentoRepository _repository;

  List<Equipamento> _equipamentos = [];

  bool _carregando = false;

  String? _errorMessage;

  List<Equipamento> get equipamentos => List.unmodifiable(_equipamentos);

  bool get carregando => _carregando;

  String? get errorMessage => _errorMessage;

  int get quantidadeEquipamentos => _equipamentos.length;

  List<Equipamento> equipamentosDoCliente(int clienteId) {
    return _equipamentos
        .where((equipamento) => equipamento.clienteId == clienteId)
        .toList();
  }

  Future<void> carregarEquipamentos() async {
    _carregando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _equipamentos = await _repository.listar();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os equipamentos.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarEquipamentosPorCliente(int clienteId) async {
    _carregando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _equipamentos = await _repository.listarPorCliente(clienteId);
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os equipamentos do cliente.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> salvarEquipamento(Equipamento equipamento) async {
    _errorMessage = null;
    notifyListeners();

    try {
      if (equipamento.id == null) {
        await _repository.inserir(equipamento);
      } else {
        await _repository.atualizar(equipamento);
      }

      await carregarEquipamentos();

      return true;
    } catch (e) {
      _errorMessage = equipamento.id == null
          ? 'Não foi possível cadastrar o equipamento.'
          : 'Não foi possível atualizar o equipamento.';

      notifyListeners();

      return false;
    }
  }

  Future<bool> excluirEquipamento(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.excluir(id);

      await carregarEquipamentos();

      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível excluir o equipamento.';

      notifyListeners();

      return false;
    }
  }

  Future<Equipamento?> buscarEquipamentoPorId(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.buscarPorId(id);
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar o equipamento.';

      notifyListeners();

      return null;
    }
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }
}
